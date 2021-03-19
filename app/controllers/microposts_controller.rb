class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build micropost_params
    @micropost.image.attach micropost_params[:image]

    if @micropost.save
      flash[:success] = t "flash.create_micropost_success"
      redirect_to root_path
    else
      @feed_items = paginate current_user.feed.by_created_at
      render "static_pages/home"
    end
  end

  def destroy
    if @micropost.destroy
      flash[:success] = t "flash.delete_micropost_success"
    else
      flash[:danger] = t "flash.delete_micropost_error"
    end
    redirect_to request.referer || root_path
  end

  private

  def micropost_params
    params.require(:micropost).permit :content, :image
  end

  def correct_user
    @micropost = current_user.microposts.find_by id: params[:id]
    return if @micropost

    flash[:danger] = t "flash.can't_delete_micropost"
    redirect_to root_path
  end
end
