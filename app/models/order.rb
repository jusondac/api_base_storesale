# Attributes for the Order model:
# - id: integer
# - customer_id: integer
# - total_price: decimal
# - status: string
# - created_at: datetime
# - updated_at: datetime
class Order < ApplicationRecord
  has_one :invoice, dependent: :destroy
  belongs_to :customer
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items
  has_many :products, through: :order_items

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: %w[pending completed canceled processing] }
end
