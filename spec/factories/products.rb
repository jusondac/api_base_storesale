FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    price { Faker::Commerce.price }
    quantity { Faker::Number.between(from: 10, to: 100) }
    association :category
    association :storefront
  end
end
