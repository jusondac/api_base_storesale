#             :id => :integer,
#           :email => :string,
# :password_digest => :string,
#      :created_at => :datetime,
#      :updated_at => :datetime,
#            :role => :integer,
#            :name => :string,
#           :phone => :string,
#        :verified => :boolean
class User < ApplicationRecord
    has_secure_password

    validates :email, presence: true, uniqueness: true
    validates :password, presence: true, length: { minimum: 6 }, if: :password

    has_many :storefronts, dependent: :destroy
    has_many :products, through: :storefronts
    has_many :orders, foreign_key: 'customer_id', dependent: :destroy
    has_many :shippings, dependent: :destroy, foreign_key: 'customer_id'

    enum :role, [:master, :admin, :customer]
    scope :customers, -> { where(role: :customer) }
   
end
