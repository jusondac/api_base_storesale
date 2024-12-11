class Payment < ApplicationRecord
  belongs_to :invoice
  validates :amount, numericality: { greater_than: 0 }
  validates :status, presence: true
  validates :invoice, presence: true

  enum :status, [:pending, :completed, :failed]
end
