class ChangeUnitPriceFromOrderItem < ActiveRecord::Migration[8.0]
  def change
    change_column :order_items, :unit_price, :float, precision: 10, scale: 2
  end
end
