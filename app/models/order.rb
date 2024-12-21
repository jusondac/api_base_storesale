# Attributes for the Order model:
# - id: integer
# - customer_id: integer
# - total_price: decimal
# - status: string
# - created_at: datetime
# - updated_at: datetime
class Order < ApplicationRecord
  has_one :invoice, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  has_many :order_discounts, dependent: :destroy
  has_many :discounts, through: :order_discounts, dependent: :destroy
  belongs_to :customer, class_name: 'User', foreign_key: 'customer_id'
  accepts_nested_attributes_for :order_items

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: %w[pending completed canceled processing] }

  scope :completed, -> { where(status: 'completed') }
  scope :pending, -> { where(status: 'pending') }
  scope :canceled, -> { where(status: 'canceled') }
  scope :processing, -> { where(status: 'processing') }
  # Calculate total revenue for a specific storefront through the orders' products
  scope :total_revenue, ->(storefront_id) {
    joins(products: :storefront)
      .where('storefronts.id = ?', storefront_id)
      .select('storefronts.*, SUM(orders.total_price) as total_revenue')
      .group('storefronts.id')
  }

  def detailed_items
    order_items
      .joins(:product)
      .select('
        order_items.*,
        products.name as product_name,
        products.price as current_price,
        (order_items.quantity * order_items.unit_price) as subtotal
      ')
  end

  def summary
    {
      order_id: id,
      customer: customer.name,
      total_items: order_items.sum(&:quantity),
      total_price: total_price,
      storefronts: order_items.map { |item| item.product.storefront.name }.uniq,
      status: status,
      created_at: created_at
    }
  end
end
