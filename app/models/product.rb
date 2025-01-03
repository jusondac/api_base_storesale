class Product < ApplicationRecord
    has_one :stock, dependent: :destroy
    has_many :restocks, dependent: :destroy
    belongs_to :category
    belongs_to :storefront
    has_many :order_items
    has_many :orders, through: :order_items
  
    validates :name, :price, :quantity, presence: true
    validates :price, numericality: { greater_than_or_equal_to: 0 }
    validates :quantity, numericality: { greater_than_or_equal_to: 0 }
end
