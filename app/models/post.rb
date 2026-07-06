class Post < ApplicationRecord
  include PgSearch::Model

  before_validation :generate_slug, if: -> { slug.blank? }
  before_save :render_markdown

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :body_markdown, presence: true

  scope :published, -> { where(published: true) }

  pg_search_scope :search_by_content,
    against: { title: "A", body_markdown: "B" },
    using: { tsearch: { prefix: true } }

  def to_param
    slug
  end

  def excerpt(max_length: 200)
    first_paragraph = body_markdown.to_s.split(/\n\s*\n/, 2).first.to_s
    plain = first_paragraph
      .gsub(/!\[.*?\]\(.*?\)/, "")
      .gsub(/\[([^\]]*)\]\(.*?\)/, '\1')
      .gsub(/[*_~`#>]/, "")
      .squish
    plain.truncate(max_length, separator: /\s/)
  end

  def reading_time_minutes
    words = body_markdown.to_s.split(/\s+/).reject(&:blank?).size
    [ (words / 200.0).ceil, 1 ].max
  end

  private

  def generate_slug
    self.slug = title&.parameterize
  end

  # Mantém body_html sempre sincronizado com body_markdown.
  def render_markdown
    self.body_html = MarkdownRenderer.render(body_markdown) if body_markdown_changed? || body_html.blank?
  end
end
