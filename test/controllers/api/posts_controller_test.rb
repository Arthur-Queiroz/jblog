require "test_helper"

class Api::PostsControllerTest < ActionDispatch::IntegrationTest
  test "index returns published posts as JSON" do
    get api_posts_path, as: :json
    assert_response :success
    assert_equal "application/json", response.media_type

    body = JSON.parse(response.body)
    assert_kind_of Array, body
    assert_equal 1, body.size

    post_data = body.first
    assert_equal "post-publicado", post_data["slug"]
    assert_equal "Post publicado", post_data["title"]
    assert_kind_of String, post_data["excerpt"]
    assert_match %r{/posts/post-publicado}, post_data["url"]
    assert_kind_of String, post_data["publishedAt"]
    assert_kind_of Integer, post_data["readingTimeMinutes"]
    assert_kind_of Array, post_data["tags"]
  end

  test "index excludes draft posts" do
    get api_posts_path, as: :json
    body = JSON.parse(response.body)
    slugs = body.map { |p| p["slug"] }
    assert_not_includes slugs, "rascunho"
  end

  test "index orders by published_at descending" do
    Post.create!(
      title: "Post antigo",
      slug: "post-antigo",
      body_markdown: "Conteudo antigo",
      published: true,
      published_at: 1.week.ago
    )
    Post.create!(
      title: "Post recente",
      slug: "post-recente",
      body_markdown: "Conteudo recente",
      published: true,
      published_at: 1.hour.ago
    )

    get api_posts_path, as: :json
    body = JSON.parse(response.body)
    slugs = body.map { |p| p["slug"] }
    assert_equal "post-recente", slugs.first
  end

  test "index respects limit parameter" do
    3.times do |i|
      Post.create!(
        title: "Post #{i}",
        slug: "post-#{i}",
        body_markdown: "Conteudo #{i}",
        published: true,
        published_at: i.hours.ago
      )
    end

    get api_posts_path(limit: 2), as: :json
    body = JSON.parse(response.body)
    assert_equal 2, body.size
  end

  test "index sets cache headers" do
    get api_posts_path, as: :json
    assert_match(/public/, response.headers["Cache-Control"])
    assert_match(/max-age=300/, response.headers["Cache-Control"])
  end

  test "publishedAt is ISO-8601 date format" do
    get api_posts_path, as: :json
    body = JSON.parse(response.body)
    date = body.first["publishedAt"]
    assert_match(/\A\d{4}-\d{2}-\d{2}\z/, date)
  end

  test "url is absolute" do
    get api_posts_path, as: :json
    body = JSON.parse(response.body)
    url = body.first["url"]
    assert_match %r{\Ahttps?://}, url
  end

  test "readingTimeMinutes is at least 1" do
    get api_posts_path, as: :json
    body = JSON.parse(response.body)
    assert body.first["readingTimeMinutes"] >= 1
  end
end
