class CreateRestocks < ActiveRecord::Migration[7.2]
  def change
    create_table :restocks do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :quantity
      t.datetime :restocked_at
      t.references :supplier, null: false, foreign_key: true

      t.timestamps
    end
  end
end
