# == Schema Information
#
# Table name: restocks
#
#  id         :bigint           not null, primary key
#  product_id :bigint           not null
#  supplier_id:bigint           not null
#  quantity   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Restock < ApplicationRecord
  belongs_to :product
  belongs_to :supplier

  validates :quantity, numericality: { greater_than: 0 }
end
