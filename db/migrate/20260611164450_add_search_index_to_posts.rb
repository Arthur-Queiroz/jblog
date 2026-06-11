class AddSearchIndexToPosts < ActiveRecord::Migration[8.1]
  def up
    enable_extension "pg_trgm"

    execute <<~SQL
      CREATE INDEX index_posts_on_search
      ON posts
      USING gin ((title || ' ' || coalesce(body_markdown, '')) gin_trgm_ops)
    SQL
  end

  def down
    execute "DROP INDEX IF EXISTS index_posts_on_search"
    disable_extension "pg_trgm"
  end
end
