class Discount < ApplicationRecord
  belongs_to :storefront
  has_many :order_discounts, dependent: :destroy
  has_many :order, through: :order_discounts, dependent: :destroy
end
