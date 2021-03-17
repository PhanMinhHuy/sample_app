class StaticPagesController < ApplicationController
  def home
    return unless logged_in?

    @micropost = current_user.microposts.build
    @feed_items = paginate current_user.feed.by_created_at
  end

  def help; end
end
