require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "valid post" do
    post = Post.new(title: "Teste", body_markdown: "Conteúdo")
    assert post.valid?
  end

  test "requires title" do
    post = Post.new(body_markdown: "Conteúdo")
    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
  end

  test "requires body_markdown" do
    post = Post.new(title: "Teste")
    assert_not post.valid?
    assert_includes post.errors[:body_markdown], "can't be blank"
  end

  test "generates slug from title when blank" do
    post = Post.new(title: "Meu Post Legal", body_markdown: "Conteúdo")
    post.valid?
    assert_equal "meu-post-legal", post.slug
  end

  test "does not overwrite existing slug" do
    post = Post.new(title: "Meu Post", slug: "slug-custom", body_markdown: "Conteúdo")
    post.valid?
    assert_equal "slug-custom", post.slug
  end

  test "slug must be unique" do
    Post.create!(title: "Original", slug: "original", body_markdown: "Conteúdo")
    duplicate = Post.new(title: "Outro", slug: "original", body_markdown: "Conteúdo")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "renders markdown to html on save" do
    post = Post.create!(title: "Render", body_markdown: "**negrito**")
    assert_includes post.body_html, "<strong>negrito</strong>"
  end

  test "re-renders html when markdown changes" do
    post = posts(:published_post)
    post.update!(body_markdown: "Novo _conteúdo_")
    assert_includes post.body_html, "<em>conteúdo</em>"
  end

  test "published scope returns only published posts" do
    assert_includes Post.published, posts(:published_post)
    assert_not_includes Post.published, posts(:draft_post)
  end

  test "to_param returns slug" do
    post = posts(:published_post)
    assert_equal "post-publicado", post.to_param
  end

  test "body_html is sanitized on save" do
    post = Post.create!(title: "Malicioso", body_markdown: %(texto <img src="x" onerror="alert(1)"> <script>alert(2)</script>))
    assert_not_includes post.body_html, "onerror"
    assert_not_includes post.body_html, "<script"
  end
end
