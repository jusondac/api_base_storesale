FactoryBot.define do
  factory :stock do
    association :product
    quantity { 1 }
    last_updated_at { "2024-12-08 14:12:45" }
  end
end
