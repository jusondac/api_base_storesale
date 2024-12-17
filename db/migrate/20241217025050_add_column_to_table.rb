class AddColumnToTable < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :cost, :float, precision: 10, scale: 2
    change_column :products, :price, :float, precision: 10, scale: 2
    add_reference :suppliers, :owner, foreign_key: { to_table: :users }
    add_column :storefronts, :margin, :float
  end
end
