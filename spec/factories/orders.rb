FactoryBot.define do
  factory :order do
    status { "pending" }
    total_price { 100.0 }
    association :customer
  end
end
