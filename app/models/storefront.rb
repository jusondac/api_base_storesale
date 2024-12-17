class Storefront < ApplicationRecord
  belongs_to :user
  has_many :products, dependent: :destroy
  has_many :order_items, through: :products

  validates :name, presence: true
  validates :user_id, presence: true
  validates :city, presence: true
  validates :address, presence: true

  def owner;user;end

  def products_sold
    order_items.map(&:product).uniq
  end
end
