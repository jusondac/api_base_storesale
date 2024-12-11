class AddStorefrontToProducts < ActiveRecord::Migration[8.0]
  def change
    add_reference :products, :storefront, foreign_key: true, null: true
  end
end
