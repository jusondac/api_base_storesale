FactoryBot.define do
  factory :shipping do
    address { Faker::Address.full_address }
    title { "Home" }
    association :customer, factory: :user
  end
end
