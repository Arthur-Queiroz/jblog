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

  test "preserves rouge highlight spans in code blocks" do
    markdown = "```ruby\nputs 'hello'\n```"
    html = MarkdownRenderer.render(markdown)
    assert_includes html, "<span"
    assert_includes html, "highlight"
  end

  test "strips script tags" do
    html = MarkdownRenderer.render("<script>alert('xss')</script>")
    assert_not_includes html, "<script"
  end

  test "strips event handler attributes" do
    html = MarkdownRenderer.render('<img src="x" onerror="alert(1)">')
    assert_not_includes html, "onerror"
  end

  test "strips svg with onload" do
    html = MarkdownRenderer.render('<svg onload="alert(1)"></svg>')
    assert_not_includes html, "onload"
    assert_not_includes html, "<svg"
  end

  test "strips javascript: hrefs" do
    html = MarkdownRenderer.render('<a href="javascript:alert(1)">clique</a>')
    assert_not_includes html, "javascript:"
  end

  test "strips iframes" do
    html = MarkdownRenderer.render('<iframe src="https://evil.example"></iframe>')
    assert_not_includes html, "<iframe"
  end

  test "keeps benign inline html" do
    html = MarkdownRenderer.render("texto com <abbr title=\"Hypertext\">HTML</abbr> benigno")
    assert_includes html, "<abbr"
    assert_includes html, 'title="Hypertext"'
  end
end
