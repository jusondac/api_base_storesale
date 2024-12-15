# Attributes for the Shipping model
# t.string :tracking_number
# t.string :carrier
# t.date :shipped_date
# t.date :estimated_delivery_date
# t.references :customer, foreign_key: true
class Shipping < ApplicationRecord
  belongs_to :customer
end