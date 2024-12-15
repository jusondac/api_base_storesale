class AddAddressToCustomer < ActiveRecord::Migration[8.0]
  def change
    add_column :customers, :address, :string
  end
end
