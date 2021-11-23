class AddArticleType < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      CREATE TYPE article_type AS ENUM ('article', 'podcast', 'unknown');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE article_type;
    SQL
  end
end
