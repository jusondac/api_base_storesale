FactoryBot.define do
  factory :restock do
    association :product
    quantity { 1 }
    restocked_at { "2024-12-08 14:12:49" }
    supplier { nil }
  end
end
