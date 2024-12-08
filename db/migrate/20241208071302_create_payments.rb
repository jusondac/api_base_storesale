class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.references :invoice, null: false, foreign_key: true
      t.decimal :amount
      t.string :status
      t.datetime :payment_date
      t.string :payment_method

      t.timestamps
    end
  end
end
