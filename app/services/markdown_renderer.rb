require "cgi"

class MarkdownRenderer
  # Allowlist do Rails mais as tags que o GFM gera (tabelas). Tudo fora disso é removido.
  # "class" é necessário para os tokens do rouge (.highlight .k etc., ver application.css).
  ALLOWED_TAGS = (Rails::HTML5::SafeListSanitizer.allowed_tags + %w[table thead tbody tr td th]).freeze
  ALLOWED_ATTRIBUTES = (Rails::HTML5::SafeListSanitizer.allowed_attributes + %w[class]).freeze

  def self.render(markdown)
    # syntax_highlighter: nil desliga o syntect embutido do commonmarker, que gera
    # <span style="..."> inline (incompatível com a CSP e com a sanitização).
    # O highlight é responsabilidade do rouge, com classes CSS (abaixo).
    html = Commonmarker.to_html(markdown, options: commonmarker_options, plugins: { syntax_highlighter: nil })
    html = highlight_code_blocks(html)
    sanitize(html)
  end

  def self.commonmarker_options
    {
      parse: { smart: true },
      # github_pre_lang: false gera <pre><code class="language-x">, o formato que
      # highlight_code_blocks espera.
      render: { hardbreaks: false, unsafe: true, github_pre_lang: false },
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

  # O body_html é servido com `raw` na leitura pública, então a segurança fica toda aqui,
  # no momento do render. `unsafe: true` deixa o autor usar HTML no Markdown, e o tagfilter
  # do commonmarker barra <script>/<iframe> — mas NÃO barra atributos de evento
  # (<img onerror=...>) nem <svg onload=...>. A sanitização fecha esse buraco: se a conta
  # admin for comprometida, um post malicioso não vira XSS persistente para os leitores.
  def self.sanitize(html)
    Rails::HTML5::SafeListSanitizer.new.sanitize(html, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
  end
end
