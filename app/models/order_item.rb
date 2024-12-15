# Attributes for OrderItem model:
# - id: integer
# - order_id: integer
# - product_id: integer
# - quantity: integer
# - unit_price: decimal
# - created_at: datetime
# - updated_at: datetime
class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product
  validates :quantity, :unit_price, numericality: { greater_than: 0 }
end
