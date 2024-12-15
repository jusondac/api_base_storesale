# Attributes for the Order model
# t.integer :customer_id
# t.decimal :total_price, precision: 10, scale: 2
# t.string :status
# t.datetime :created_at, null: false
# t.datetime :updated_at, null: false
class Order < ApplicationRecord
  has_one :invoice, dependent: :destroy
  belongs_to :customer
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items
  has_many :products, through: :order_items

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: %w[pending completed canceled processing] }
end
