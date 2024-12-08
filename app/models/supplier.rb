class Supplier < ApplicationRecord
  has_many :restocks, dependent: :destroy

  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
