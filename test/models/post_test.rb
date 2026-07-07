require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "valid post" do
    post = Post.new(title: "Teste", body_markdown: "Conteúdo")
    assert post.valid?
  end

  test "requires title" do
    post = Post.new(body_markdown: "Conteúdo")
    assert_not post.valid?
    assert_includes post.errors[:title], "não pode ficar em branco"
  end

  test "requires body_markdown" do
    post = Post.new(title: "Teste")
    assert_not post.valid?
    assert_includes post.errors[:body_markdown], "não pode ficar em branco"
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
    assert_includes duplicate.errors[:slug], "já está em uso"
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

  test "excerpt returns first paragraph as plain text" do
    post = Post.new(body_markdown: "Primeiro **parágrafo** com _formatação_.\n\nSegundo parágrafo.")
    assert_equal "Primeiro parágrafo com formatação.", post.excerpt
  end

  test "excerpt strips markdown links" do
    post = Post.new(body_markdown: "Texto com [link](https://example.com) aqui.")
    assert_equal "Texto com link aqui.", post.excerpt
  end

  test "excerpt truncates at 200 characters" do
    long_text = "a " * 150
    post = Post.new(body_markdown: long_text)
    assert post.excerpt.length <= 200
  end

  test "excerpt handles empty body" do
    post = Post.new(body_markdown: "")
    assert_equal "", post.excerpt
  end

  test "reading_time_minutes returns at least 1" do
    post = Post.new(body_markdown: "Poucas palavras.")
    assert_equal 1, post.reading_time_minutes
  end

  test "reading_time_minutes calculates from word count" do
    post = Post.new(body_markdown: "palavra " * 400)
    assert_equal 2, post.reading_time_minutes
  end
end
