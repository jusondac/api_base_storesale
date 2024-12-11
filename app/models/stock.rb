# class Stock < ApplicationRecord {
#                  :id => :integer,
#          :product_id => :integer,
#            :quantity => :integer,
#     :last_updated_at => :datetime,
#          :created_at => :datetime,
#          :updated_at => :datetime
# }
class Stock < ApplicationRecord
  belongs_to :product

  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
end
