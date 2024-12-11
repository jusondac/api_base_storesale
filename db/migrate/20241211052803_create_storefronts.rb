class CreateStorefronts < ActiveRecord::Migration[8.0]
  def change
    create_table :storefronts do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true
      t.string :address
      t.string :city
      t.timestamps
    end
  end
end
