class Customer < ApplicationRecord
    has_many :orders, dependent: :destroy
    has_many :shippings, dependent: :destroy

    validates :name, :email, :phone, presence: true
    validates :email, uniqueness: true
    # validates :phone, length: { minimum: 10, maximum: 15 }
end
