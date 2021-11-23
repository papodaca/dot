class CreateDirectories < ActiveRecord::Migration[7.0]
  def change
    create_table :directories, id: :uuid do |t|
      t.text :title
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
