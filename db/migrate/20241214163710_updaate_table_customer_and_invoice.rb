class UpdaateTableCustomerAndInvoice < ActiveRecord::Migration[8.0]
  def change
    add_reference :invoices, :shipping, foreign_key: true, null: true
    remove_column :customers, :address
  end
end
