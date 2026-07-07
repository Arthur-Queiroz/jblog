class PostsController < ApplicationController
  allow_unauthenticated_access
  def index
    posts = Post.published.order(published_at: :desc)
    # Home do redesign: caixa "Destaques" com os mais recentes e o restante
    # agrupado por mês de publicação ("2026 - Julho").
    @featured_posts = posts.first(3)
    @posts_by_month = posts.group_by { |post| (post.published_at || post.created_at).beginning_of_month }
  end

  def show
    @post = Post.published.find_by!(slug: params[:slug])
  end
end
