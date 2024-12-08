class CreateInvoices < ActiveRecord::Migration[7.2]
  def change
    create_table :invoices do |t|
      t.references :order, null: false, foreign_key: true
      t.string :status
      t.decimal :total_amount
      t.datetime :due_date

      t.timestamps
    end
  end
end
