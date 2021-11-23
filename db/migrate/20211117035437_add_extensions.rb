class AddExtensions < ActiveRecord::Migration[7.0]
  def change
    execute <<-SQL
      CREATE EXTENSION IF NOT EXISTS pg_trgm;
      CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
    SQL
  end
end
