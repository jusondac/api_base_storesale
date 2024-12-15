# Attributes for Category model:
# - id: integer, not null, primary key
# - name: string, not null, unique
# - created_at: datetime, not null
# - updated_at: datetime, not null

class Category < ApplicationRecord
    has_many :products, dependent: :destroy
    
    validates :name, presence: true, uniqueness: true
end
