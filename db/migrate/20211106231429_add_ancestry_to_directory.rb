class AddAncestryToDirectory < ActiveRecord::Migration[7.0]
  def change
    add_column :directories, :ancestry, :string
    add_index :directories, :ancestry
  end
end
