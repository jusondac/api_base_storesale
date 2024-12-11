FactoryBot.define do
  factory :restock do
    association :product
    quantity { 100 }
    restocked_at { "2024-12-08 14:12:49" }
    supplier
  end
end
