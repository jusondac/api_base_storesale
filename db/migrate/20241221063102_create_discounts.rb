class CreateDiscounts < ActiveRecord::Migration[8.0]
  def change
    create_table :discounts do |t|
      t.string :code
      t.integer :percentage
      t.datetime :start_date
      t.datetime :end_date
      t.references :storefront, null: false, foreign_key: true

      t.timestamps
    end
  end
end
