class RelationshipsController < ApplicationController
  before_action :logged_in_user
  before_action :load_user_followed, only: :create
  before_action :load_relationship, only: :destroy

  def create
    current_user.follow @user
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  def destroy
    @user = @relationship.followed
    current_user.unfollow @user
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  private

  def load_user_followed
    @user = User.find_by id: params[:followed_id]
    return if @user

    flash[:danger] = t "flash.not_found_user"
    redirect_to new_user_path
  end

  def load_relationship
    @relationship = Relationship.find_by(id: params[:id])
    return if @relationship

    flash[:danger] = t "flash.not_found_relationship"
    redirect_to root_path
  end
end
