class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(new create)
  before_action :load_user, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = paginate User.where_activated.by_created_at
  end

  def show
    @microposts = paginate @user.microposts.by_created_at
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "flash.activate_message"
      redirect_to root_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t "flash.profile_updated"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = "#{t 'flash.user_deleted_success'}: #{@user.name}"
    else
      flash[:danger] = t "flash.user_deleted_error"
    end
    redirect_to users_path
  end

  def following
    @title = t "users_page.following"
    @users = paginate @user.following
    render "show_follow"
  end

  def followers
    @title = t "users_page.followers"
    @users = paginate @user.followers
    render "show_follow"
  end

  private

  def user_params
    params.require(:user)
          .permit :name, :email, :password, :password_confirmation
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "flash.not_found_user"
    redirect_to new_user_path
  end

  # Confirms the correct user.
  def correct_user
    redirect_to root_path unless current_user? @user
  end

  # Confirms an admin user.
  def admin_user
    redirect_to root_path unless current_user.admin?
  end
end
