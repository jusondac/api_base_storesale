class User < ApplicationRecord
    has_secure_password

    validates :email, presence: true, uniqueness: true
    validates :password, presence: true, length: { minimum: 6 }, if: :password

    has_many :storefronts, dependent: :destroy
    has_many :products, through: :storefronts
    
    enum :role, [:master, :admin, :customer]

   
end
