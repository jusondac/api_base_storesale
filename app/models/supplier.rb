class Supplier < ApplicationRecord
  has_many :restocks, dependent: :destroy
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'

  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
