require "cgi"

class MarkdownRenderer
  def self.render(markdown)
    html = Commonmarker.to_html(markdown, options: commonmarker_options)
    highlight_code_blocks(html)
  end

  def self.commonmarker_options
    {
      parse: { smart: true },
      render: { hardbreaks: false, unsafe: true },
      extension: { table: true, strikethrough: true, autolink: true, tagfilter: true },
      commonmark: { em: [ "*", "_" ], strong: [ "**", "__" ] }
    }
  end

  # Aplica syntax highlight nos blocos de código usando rouge.
  def self.highlight_code_blocks(html)
    html.gsub(%r{<pre><code(?:\s+class="language-([^"]+)")?>(.*?)</code></pre>}m) do
      language = Regexp.last_match(1)
      code = CGI.unescapeHTML(Regexp.last_match(2))
      lexer = Rouge::Lexer.find(language) || Rouge::Lexers::PlainText.new
      formatter = Rouge::Formatters::HTML.new
      highlighted = formatter.format(lexer.lex(code))
      %(<pre class="highlight"><code>#{highlighted}</code></pre>)
    end
  end
end
