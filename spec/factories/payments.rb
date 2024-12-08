FactoryBot.define do
  factory :payment do
    invoice { nil }
    amount { "9.99" }
    status { "MyString" }
    payment_date { "2024-12-08 14:13:03" }
    payment_method { "MyString" }
  end
end
