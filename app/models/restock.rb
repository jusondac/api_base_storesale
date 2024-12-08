class Restock < ApplicationRecord
  belongs_to :product
  belongs_to :supplier

  validates :quantity, numericality: { greater_than: 0 }
end
