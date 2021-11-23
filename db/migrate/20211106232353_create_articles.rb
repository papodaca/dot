class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles, id: :uuid do |t|
      t.text :title
      t.text :url
      t.text :remote_id
      t.text :description
      t.text :author
      t.datetime :pub_date
      t.boolean :star
      t.datetime :read
      t.json :itunes
      t.column :kind, :article_type, default: 'article'
      t.references :feed, null: false, foreign_key: true, type: :uuid
      t.column :tsv_description, :tsvector
      t.column :tsv_title, :tsvector

      t.timestamps
    end

    add_index :articles, [:feed_id, :remote_id], :unique => true

    create_trigger(compatibility: 1).on(:articles).before(:insert, :update) do
      <<-SQL
        new.tsv_description := to_tsvector('pg_catalog.english', coalesce(new.description,''));
        new.tsv_title := to_tsvector('pg_catalog.english', coalesce(new.title,''));
      SQL
    end
  end
end
