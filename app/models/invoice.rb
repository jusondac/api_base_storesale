# Attributes for the Invoice model
# t.integer :order_id
# t.integer :shipping_id
# t.string :status
# t.timestamps
class Invoice < ApplicationRecord
  belongs_to :order
  belongs_to :shipping
  has_many :payments, dependent: :destroy

  validates :status, inclusion: { in: %w[pending paid overdue] }
end
