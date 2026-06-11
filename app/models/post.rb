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

  private

  def generate_slug
    self.slug = title&.parameterize
  end

  # Mantém body_html sempre sincronizado com body_markdown.
  def render_markdown
    self.body_html = MarkdownRenderer.render(body_markdown) if body_markdown_changed? || body_html.blank?
  end
end
