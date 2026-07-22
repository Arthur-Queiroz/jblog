class NormalizePostSlugs < ActiveRecord::Migration[8.0]
  class PostRecord < ActiveRecord::Base
    self.table_name = "posts"
  end

  def up
    posts = PostRecord.order(:id).pluck(:id, :slug, :title)

    # Evita colisões temporárias, como entre "Meu Post" e "meu-post".
    posts.each do |post_id, _slug, _title|
      PostRecord.where(id: post_id).update_all(slug: temporary_slug(post_id))
    end

    posts.each do |post_id, slug, title|
      slug_source = slug.presence || title.presence
      normalized_slug = slug_source&.parameterize.presence || "post-#{post_id}"
      PostRecord.where(id: post_id).update_all(slug: unique_slug(normalized_slug))
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Não é possível recuperar os slugs originais."
  end

  private

  def temporary_slug(post_id)
    candidate = "normalizing-post-#{post_id}"
    suffix = 2

    while PostRecord.where.not(id: post_id).exists?(slug: candidate)
      candidate = "normalizing-post-#{post_id}-#{suffix}"
      suffix += 1
    end

    candidate
  end

  def unique_slug(slug)
    candidate = slug
    suffix = 2

    while PostRecord.exists?(slug: candidate)
      candidate = "#{slug}-#{suffix}"
      suffix += 1
    end

    candidate
  end
end
