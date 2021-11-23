class CreateArticlesTags < ActiveRecord::Migration[7.0]
  def change
    create_join_table :articles, :tags, column_options: { type: :uuid }
  end
end
