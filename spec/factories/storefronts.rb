FactoryBot.define do
  factory :storefront do
    name { "MyString" }
    city { Faker::Address.city }    
    address { Faker::Address.street_address }
    user
  end
end
