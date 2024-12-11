class ChangeColumnQuantityOrder < ActiveRecord::Migration[8.0]
  def change
    change_column :products, :quantity, :integer, :default => 0
    #Ex:- :default =>''
    #Ex:- change_column("admin_users", "email", :string, :limit =>25)
  end
end
