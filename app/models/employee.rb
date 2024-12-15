# Attributes for Employee model:
# - name: string
# - role: string
# - email: string
class Employee < ApplicationRecord
    validates :name, :role, :email, presence: true
end
