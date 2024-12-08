class CreateStocks < ActiveRecord::Migration[7.2]
  def change
    create_table :stocks do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :quantity
      t.datetime :last_updated_at

      t.timestamps
    end
  end
end
