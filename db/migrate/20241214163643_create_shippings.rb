class CreateShippings < ActiveRecord::Migration[8.0]
  def change
    create_table :shippings do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :address
      t.string :title

      t.timestamps
    end
  end
end
