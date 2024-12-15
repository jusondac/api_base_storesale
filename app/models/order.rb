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
  belongs_to :user
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items
  has_many :products, through: :order_items

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: %w[pending completed canceled processing] }

  # Calculate total revenue for a specific storefront through the orders' products
  scope :total_revenue, ->(storefront_id) {
    joins(products: :storefront)
      .where('storefronts.id = ?', storefront_id)
      .select('storefronts.*, SUM(orders.total_price) as total_revenue')
      .group('storefronts.id')
  }
  scope :completed, -> { where(status: 'completed') }
  scope :pending, -> { where(status: 'pending') }
  scope :canceled, -> { where(status: 'canceled') }
  scope :processing, -> { where(status: 'processing') }
end
