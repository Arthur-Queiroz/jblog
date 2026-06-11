class PostsController < ApplicationController
  allow_unauthenticated_access
  def index
    @posts = Post.published.order(published_at: :desc)
  end

  def show
    @post = Post.published.find_by!(slug: params[:slug])
  end
end
