class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product
  validates :quantity, :unit_price, numericality: { greater_than: 0 }
end
