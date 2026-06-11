class SearchController < ApplicationController
  allow_unauthenticated_access
  def index
    @query = params[:q].to_s.strip
    @search_results = if @query.present?
      Post.published.search_by_content(@query)
    else
      Post.none
    end
  end
end
