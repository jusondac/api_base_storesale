FactoryBot.define do
  factory :invoice do
    association :order
    status { "MyString" }
    total_amount { "9.99" }
    due_date { "2024-12-08 14:12:59" }
  end
end
