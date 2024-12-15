FactoryBot.define do
  factory :shipping do
    customer
    address { Faker::Address.full_address }
    title { "Home" }
  end
end
