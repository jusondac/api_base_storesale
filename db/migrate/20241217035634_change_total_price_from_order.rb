class ChangeTotalPriceFromOrder < ActiveRecord::Migration[8.0]
  def change
    change_column :orders, :total_price, :float, precision: 10, scale: 2
  end
end
