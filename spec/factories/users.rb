FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    role { 2 }
    name { Faker::Name.name }
    phone { Faker::PhoneNumber.phone_number }
    verified { true }
  end
end
