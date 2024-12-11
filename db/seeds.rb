# seeds.rb

require 'faker'

# Clear existing data
Restock.destroy_all
Stock.destroy_all
OrderItem.destroy_all
Order.destroy_all
Invoice.destroy_all
Payment.destroy_all
Product.destroy_all
Supplier.destroy_all
Customer.destroy_all
Category.destroy_all
Employee.destroy_all
User.destroy_all
Storefront.destroy_all

# Create Users
puts "Creating users..."
5.times do
  User.create!(
    email: Faker::Internet.unique.email,
    password: 'password'
  )
end

# Create Storefronts
puts "Creating storefronts..."
storefronts = []
5.times do
  storefronts << Storefront.create!(
    name: Faker::Company.name,
    user_id: User.all.sample.id,
    address: Faker::Address.street_address,
    city: Faker::Address.city
  )
end

# Create Categories
puts "Creating categories..."
categories = []
5.times do
  categories << Category.create!(name: Faker::Commerce.unique.department)
end

# Create Products
puts "Creating products..."
products = []
50.times do
  products << Product.create!(
    name: Faker::Commerce.product_name,
    price: Faker::Commerce.price(range: 5..100),
    quantity: Faker::Number.between(from: 10, to: 100),
    storefront_id: storefronts.sample.id,
    category: categories.sample
  )
end

# Create Suppliers
puts "Creating suppliers..."
suppliers = []
10.times do
  suppliers << Supplier.create!(
    name: Faker::Company.name,
    email: Faker::Internet.email,
    phone_number: Faker::PhoneNumber.phone_number,
    address: Faker::Address.full_address
  )
end

# Create Stocks
puts "Creating stocks..."
products.each do |product|
  Stock.create!(
    product: product,
    quantity: product.quantity,
    last_updated_at: Time.current
  )
end

# Create Employees
puts "Creating employees..."
10.times do
  Employee.create!(
    name: Faker::Name.name,
    role: Faker::Job.position,
    email: Faker::Internet.email
  )
end

# Create Customers
puts "Creating customers..."
customers = []
20.times do
  customers << Customer.create!(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    phone: Faker::PhoneNumber.phone_number
  )
end

# Create Orders
puts "Creating orders..."
orders = []
customers.each do |customer|
  rand(1..3).times do
    orders << Order.create!(
      customer: customer,
      total_price: 0, # Placeholder; will calculate below
      status: %w[pending completed canceled].sample
    )
  end
end

# Create OrderItems
puts "Creating order items..."
orders.each do |order|
  total_price = 0
  rand(1..5).times do
    product = products.sample
    quantity = Faker::Number.between(from: 1, to: 5)
    total_price += product.price * quantity

    OrderItem.create!(
      order: order,
      product: product,
      quantity: quantity,
      unit_price: product.price
    )
  end
  order.update!(total_price: total_price)
end

# Create Invoices
puts "Creating invoices..."
invoices = []
orders.each do |order|
  invoices << Invoice.create!(
    order: order,
    status: %w[pending paid overdue].sample,
    total_amount: order.total_price,
    due_date: Faker::Date.forward(days: 30)
  )
end

# Create Payments
puts "Creating payments..."
invoices.each do |invoice|
  next if invoice.status == 'overdue'

  Payment.create!(
    invoice: invoice,
    amount: invoice.total_amount,
    status: 'completed',
    payment_date: Faker::Date.backward(days: 15),
    payment_method: %w[successful failed pending].sample
  )
end

# Create Restocks
puts "Creating restocks..."
50.times do
  product = products.sample
  quantity = Faker::Number.between(from: 10, to: 50)
  supplier = suppliers.sample

  Restock.create!(
    product: product,
    quantity: quantity,
    restocked_at: Faker::Date.backward(days: 30),
    supplier: supplier
  )

  # Update product stock
  stock = Stock.find_by(product: product)
  stock.update!(
    quantity: stock.quantity + quantity,
    last_updated_at: Time.current
  )
end

puts "Seeding completed successfully!"
