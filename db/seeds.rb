require 'faker'

# Clear data
OrderItem.destroy_all
Order.destroy_all
Product.destroy_all
Category.destroy_all
Customer.destroy_all

# Seed categories
categories = 5.times.map do
  Category.create!(name: Faker::Commerce.department(max: 1, fixed_amount: true))
end

# Seed products
products = categories.flat_map do |category|
  10.times.map do
    Product.create!(
      name: Faker::Commerce.product_name,
      price: Faker::Commerce.price(range: 10.0..100.0),
      quantity: rand(10..100),
      category: category
    )
  end
end

# Seed customers
customers = 10.times.map do
  Customer.create!(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    phone: Faker::PhoneNumber.phone_number
  )
end

# Seed orders
customers.each do |customer|
  rand(1..5).times do
    items = products.sample(rand(1..3)).map do |product|
      {
        product_id: product.id,
        quantity: rand(1..5),
        unit_price: product.price
      }
    end
    OrderCreator.create_order(customer: customer, items: items)
  end
end

puts "Seeding completed!"
