class Storefront < ApplicationRecord
  belongs_to :user
  has_many :products, dependent: :destroy

  validates :name, presence: true
  validates :user_id, presence: true
  validates :city, presence: true
  validates :address, presence: true
end
