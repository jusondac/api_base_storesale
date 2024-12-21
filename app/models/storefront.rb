class Storefront < ApplicationRecord
  belongs_to :user
  has_many :products, dependent: :destroy
  has_many :order_items, through: :products
  has_many :discounts, dependent: :destroy

  validates :name, presence: true
  validates :user_id, presence: true
  validates :city, presence: true
  validates :address, presence: true

  def owner;user;end

  scope :with_completed_orders, -> {
    joins(products: { order_items: :order })
      .where(orders: { status: 'completed' })
      .distinct
  }
  
  scope :profit_margin, ->(storefront_id) {
    joins(products: :order_items)
      .select('storefronts.*, 
        SUM(order_items.quantity * (products.price - products.cost)) as total_profit,
        SUM(order_items.quantity * products.price) as total_revenue,
        (SUM(order_items.quantity * (products.price - products.cost)) / 
         NULLIF(SUM(order_items.quantity * products.price), 0) * 100.0) as margin_percentage')
      .where(storefronts: { id: storefront_id })
      .group('storefronts.id')
  }
  scope :total_revenue, -> {
    joins(products: :order_items)
      .select('storefronts.*, SUM(order_items.quantity * products.price) as total_revenue')
      .group('storefronts.id')
  }
end
