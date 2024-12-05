class Employee < ApplicationRecord
    validates :name, :role, :email, presence: true
end
