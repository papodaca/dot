class AddFeedProperties < ActiveRecord::Migration[7.0]
  def change
    add_column :feeds, :properties, :jsonb
  end
end
