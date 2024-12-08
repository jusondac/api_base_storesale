require 'faker'

# Clear existing data
OrderItem.destroy_all
Order.destroy_all
Customer.destroy_all
Product.destroy_all
Category.destroy_all
Stock.destroy_all
Restock.destroy_all
Supplier.destroy_all
Invoice.destroy_all
Payment.destroy_all
Employee.destroy_all
User.destroy_all

# Create admin user
User.create!(
  email: 'admin@example.com',
  password: 'password'
)

puts "Created admin user"

# Create categories
categories = []
5.times do
  categories << Category.create!(name: Faker::Commerce.department(max: 1))
end

puts "Created #{categories.size} categories"

# Create products and stocks
products = []
categories.each do |category|
  10.times do
    product = Product.create!(
      name: Faker::Commerce.product_name,
      price: Faker::Commerce.price(range: 10..100),
      quantity: rand(10..50),
      category: category
    )
    Stock.create!(
      product: product,
      quantity: product.quantity,
      last_updated_at: Time.now
    )
    products << product
  end
end

puts "Created #{products.size} products with associated stocks"

# Create suppliers
suppliers = []
5.times do
  suppliers << Supplier.create!(
    name: Faker::Company.name,
    email: Faker::Internet.email,
    phone_number: Faker::PhoneNumber.phone_number,
    address: Faker::Address.full_address
  )
end

puts "Created #{suppliers.size} suppliers"

# Create restocks
products.each do |product|
  rand(1..3).times do
    Restock.create!(
      product: product,
      quantity: rand(5..20),
      restocked_at: Faker::Time.backward(days: 30),
      supplier: suppliers.sample
    )
  end
end

puts "Created restock records for products"

# Create customers
customers = []
10.times do
  customers << Customer.create!(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    phone: Faker::PhoneNumber.cell_phone
  )
end

puts "Created #{customers.size} customers"

# Create orders
orders = []
customers.each do |customer|
  rand(1..3).times do
    order = Order.create!(
      customer: customer,
      total_price: 0,
      status: ['pending', 'completed', 'canceled'].sample
    )

    # Add order items
    total_price = 0
    rand(1..5).times do
      product = products.sample
      quantity = rand(1..5)
      unit_price = product.price
      OrderItem.create!(
        order: order,
        product: product,
        quantity: quantity,
        unit_price: unit_price
      )
      total_price += (quantity * unit_price)
    end

    order.update!(total_price: total_price)
    orders << order
  end
end

puts "Created #{orders.size} orders with order items"

# Create invoices
invoices = []
orders.each do |order|
  invoices << Invoice.create!(
    order: order,
    status: ['pending', 'paid', 'overdue'].sample,
    total_amount: order.total_price,
    due_date: Faker::Time.forward(days: 30)
  )
end

puts "Created #{invoices.size} invoices"

# Create payments
invoices.each do |invoice|
  rand(1..2).times do
    Payment.create!(
      invoice: invoice,
      amount: rand(1..invoice.total_amount),
      status: ['successful', 'pending', 'failed'].sample,
      payment_date: Faker::Time.backward(days: 15),
      payment_method: ['credit card', 'bank transfer', 'paypal'].sample
    )
  end
end

puts "Created payments for invoices"

# Create employees
employees = []
5.times do
  employees << Employee.create!(
    name: Faker::Name.name,
    role: ['Manager', 'Staff', 'Admin'].sample,
    email: Faker::Internet.email
  )
end

puts "Created #{employees.size} employees"

