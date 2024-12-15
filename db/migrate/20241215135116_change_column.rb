class ChangeColumn < ActiveRecord::Migration[8.0]
  def change
    remove_column :shippings, :user_id
  end
end
