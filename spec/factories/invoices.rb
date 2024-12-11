FactoryBot.define do
  factory :invoice do
    order
    status { "pending" }
    total_amount { 500.0 }
    due_date { 7.days.from_now }
  end
end
