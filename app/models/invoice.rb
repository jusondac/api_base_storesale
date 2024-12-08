class Invoice < ApplicationRecord
  belongs_to :order
  has_many :payments, dependent: :destroy

  validates :status, inclusion: { in: %w[pending paid overdue] }
end
