class CreateFeeds < ActiveRecord::Migration[7.0]
  def change
    create_table :feeds, id: :uuid do |t|
      t.text :title
      t.text :url
      t.text :link
      t.text :icon
      t.text :description
      t.json :error
      t.references :directory, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
