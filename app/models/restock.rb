# class Restock < ApplicationRecord {
#               :id => :integer,
#       :product_id => :integer,
#         :quantity => :integer,
#     :restocked_at => :datetime,
#      :supplier_id => :integer,
#       :created_at => :datetime,
#       :updated_at => :datetime
# }
class Restock < ApplicationRecord
  belongs_to :product
  belongs_to :supplier

  validates :quantity, numericality: { greater_than: 0 }
end
