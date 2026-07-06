class Api::PostsController < ActionController::API
  include Rails.application.routes.url_helpers

  def index
    posts = Post.published.order(published_at: :desc)
    posts = posts.limit(params[:limit].to_i) if params[:limit].present?

    response.headers["Cache-Control"] = "public, max-age=300"

    render json: posts.map { |post| serialize(post) }
  end

  private

  def serialize(post)
    {
      slug: post.slug,
      title: post.title,
      excerpt: post.excerpt,
      url: post_url(post),
      publishedAt: post.published_at&.to_date&.iso8601,
      readingTimeMinutes: post.reading_time_minutes,
      tags: []
    }
  end
end
