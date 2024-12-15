# This file should contain all the record creation needed to seed the database with its default values.
require 'faker'

# Clear existing data
puts "Cleaning database..."
Payment.destroy_all
Invoice.destroy_all
OrderItem.destroy_all
Order.destroy_all
Stock.destroy_all
Restock.destroy_all
Product.destroy_all
Category.destroy_all
Shipping.destroy_all
Customer.destroy_all
Supplier.destroy_all
Storefront.destroy_all
User.destroy_all
Employee.destroy_all

puts "Creating users..."
5.times do
  User.create!(
    email: Faker::Internet.unique.email,
    password_digest: BCrypt::Password.create('password123')
  )
end

puts "Creating employees..."
10.times do
  Employee.create!(
    name: Faker::Name.name,
    role: ['Manager', 'Sales', 'Support', 'Admin'].sample,
    email: Faker::Internet.unique.email
  )
end

puts "Creating suppliers..."
8.times do
  Supplier.create!(
    name: Faker::Company.name,
    email: Faker::Internet.email,
    phone_number: Faker::PhoneNumber.phone_number,
    address: Faker::Address.full_address
  )
end

puts "Creating storefronts..."
User.all.each do |user|
  2.times do
    Storefront.create!(
      name: Faker::Company.name,
      user: user,
      address: Faker::Address.street_address,
      city: Faker::Address.city
    )
  end
end

puts "Creating categories..."
categories = ['Electronics', 'Clothing', 'Books', 'Home & Garden', 'Sports'].map do |name|
  Category.create!(name: name)
end

puts "Creating products..."
Storefront.all.each do |storefront|
  rand(5..10).times do
    Product.create!(
      name: Faker::Commerce.product_name,
      price: Faker::Commerce.price(range: 10.0..1000.0),
      quantity: rand(0..100),
      category: categories.sample,
      storefront: storefront
    )
  end
end

puts "Creating stocks..."
Product.all.each do |product|
  Stock.create!(
    product: product,
    quantity: rand(10..100),
    last_updated_at: Faker::Time.between(from: 1.month.ago, to: Time.current)
  )
end

puts "Creating restocks..."
Product.all.each do |product|
  rand(1..3).times do
    Restock.create!(
      product: product,
      supplier: Supplier.all.sample,
      quantity: rand(10..50),
      restocked_at: Faker::Time.between(from: 6.months.ago, to: Time.current)
    )
  end
end

puts "Creating customers..."
20.times do
  customer = Customer.create!(
    name: Faker::Name.name,
    email: Faker::Internet.unique.email,
    phone: Faker::PhoneNumber.phone_number
  )
  
  # Create 2-3 shipping addresses for each customer
  rand(2..3).times do
    Shipping.create!(
      customer_id: customer.id,
      title: ['Home', 'Office', 'Secondary'].sample,
      address: Faker::Address.full_address
    )
  end
end

puts "Creating orders..."
Customer.all.each do |customer|
  rand(10..20).times do
    order = Order.create!(
      customer: customer,
      status: %w[pending completed canceled processing].sample,
      total_price: 0  # Will be updated after adding order items
    )

    # Create order items
    rand(1..5).times do
      product = Product.all.sample
      quantity = rand(1..5)
      OrderItem.create!(
        order: order,
        product: product,
        quantity: quantity,
        unit_price: product.price
      )
    end

    # Update order total price
    total = order.order_items.sum { |item| item.quantity * item.unit_price }
    order.update!(total_price: total)

    # Create invoice for completed orders
    if order.status == 'completed'
      invoice = Invoice.create!(
        order: order,
        shipping: customer.shippings.sample,
        status: ['pending', 'paid'].sample,
        total_amount: total,
        due_date: Faker::Time.between(from: Time.current, to: 30.days.from_now)
      )

      # Create payment for paid invoices
      if invoice.status == 'paid'
        Payment.create!(
          invoice: invoice,
          amount: invoice.total_amount,
          payment_date: Faker::Time.between(from: 30.days.ago, to: Time.current),
          payment_method: ['credit_card', 'debit_card', 'bank_transfer'].sample,
          status: :completed
        )
      end
    end
  end
end

puts "Seeding completed!"