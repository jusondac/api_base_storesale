FactoryBot.define do
  factory :payment do
    invoice
    amount { 100.00 }
    status { "completed" }
    payment_date { Time.current }
    payment_method { "credit_card" }
  end
end
