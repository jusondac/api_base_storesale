class AddRoleToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role, :integer, default: 2
    add_column :users, :name, :string
    add_column :users, :phone, :string
    add_column :users, :verified, :boolean, default: false
    rename_column :shippings, :customer_id, :user_id
    remove_reference :orders, :customer
    add_reference :orders, :customer, foreign_key: { to_table: :users }
    remove_reference :shippings, :customer
    add_reference :shippings, :customer, foreign_key: { to_table: :users }
  end
end
