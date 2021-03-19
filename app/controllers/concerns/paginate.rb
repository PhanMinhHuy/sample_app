module Paginate
  def paginate collections
    collections.paginate(page: params[:page],
      per_page: params[:per_page] || Settings.user.page.limit)
  end
end
