require "test_helper"

class MarkdownRendererTest < ActiveSupport::TestCase
  test "renders bold text" do
    html = MarkdownRenderer.render("**negrito**")
    assert_includes html, "<strong>negrito</strong>"
  end

  test "renders italic text" do
    html = MarkdownRenderer.render("_itálico_")
    assert_includes html, "<em>itálico</em>"
  end

  test "renders headings" do
    html = MarkdownRenderer.render("# Título")
    assert_match(/<h1.*>.*Título.*<\/h1>/, html)
  end

  test "renders links" do
    html = MarkdownRenderer.render("[link](https://example.com)")
    assert_includes html, 'href="https://example.com"'
  end

  test "renders code blocks" do
    markdown = "```\nputs 'hello'\n```"
    html = MarkdownRenderer.render(markdown)
    assert_includes html, "puts"
  end

  test "renders tables" do
    markdown = "| A | B |\n|---|---|\n| 1 | 2 |"
    html = MarkdownRenderer.render(markdown)
    assert_includes html, "<table>"
  end
end
