FactoryBot.define do
  factory :discount do
    code { "MyString" }
    percentage { 1 }
    start_date { "2024-12-21 13:31:04" }
    end_date { "2024-12-21 13:31:04" }
    storefront { nil }
  end
end
