class Payment < ApplicationRecord
  belongs_to :invoice

  validates :amount, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[successful failed pending] }
end
