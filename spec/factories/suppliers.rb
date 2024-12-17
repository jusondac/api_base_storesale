FactoryBot.define do
  factory :supplier do
    name { "kevin" }
    email { "kevin@email.com" }
    phone_number { "087829291121" }
    address { "Beverly st." }
    association :owner, factory: :user
  end
end
