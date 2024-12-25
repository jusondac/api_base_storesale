# require 'faker'
# require 'colorize'

# # Clear existing data
puts "Cleaning database...".yellow.bold
[
  Payment, 
  Invoice,
  OrderItem, 
  Discount,
  OrderDiscount,
  Order, 
  Stock, 
  Restock,
  Product,
  Category,
  Shipping, 
  Supplier,
  Storefront, 
  User,
  Employee
].each do |model|
  print "  - Clearing #{model.name}... ".light_red
  model.destroy_all
  puts "done!".green
end

puts "\nCreating master user...".yellow.bold
users = []
1.times do
  user = User.create!(
    email: "master@gmail1.com",
    password_digest: BCrypt::Password.create('password123'),
    phone: Faker::PhoneNumber.phone_number,
    name: Faker::Name.name,
    role: 0
  )
  puts "  - Master user created: #{user.email}".green
  users << user
end

# Create employees
puts "\nCreating admins...".yellow.bold
admins = []
5.times do |i|
  admin = User.create!(
    email: Faker::Internet.unique.email,
    password_digest: BCrypt::Password.create('password123'),
    phone: Faker::PhoneNumber.phone_number,
    name: Faker::Name.name,
    role: 1
  )
  puts "  - Admin ##{i + 1} created: #{admin.email}".green
  admins << admin
end

# Create vendors
puts "\nCreating vendors...".yellow.bold
vendors = []
5.times do |i|
  vendor = User.create!(
    email: Faker::Internet.unique.email,
    password_digest: BCrypt::Password.create('password123'),
    phone: Faker::PhoneNumber.phone_number,
    name: Faker::Name.name,
    role: 3
  )
  puts "  - Vendor ##{i + 1} created: #{vendor.email}".green
  vendors << vendor
end

puts "\nCreating customers and shippings...".yellow.bold
customers = []
10.times do |i|
  customer = User.create!(
    email: Faker::Internet.unique.email,
    password_digest: BCrypt::Password.create('password123'),
    phone: Faker::PhoneNumber.phone_number,
    name: Faker::Name.name,
    role: 2
  )
  puts "  - Customer ##{i + 1} created: #{customer.email}".green
  rand(2..3).times do
    Shipping.create!(
      customer_id: customer.id,
      title: ['Home', 'Office', 'Secondary'].sample,
      address: Faker::Address.full_address
    )
  end
  customers << customer
end

puts "\nCreating suppliers from vendors...".yellow.bold
vendors.each_with_index do |vendor, i|
  supplier = Supplier.create!(
    name: Faker::Company.name,
    email: vendor.email,
    phone_number: vendor.phone,
    owner: vendor
  )
  puts "  - Supplier ##{i + 1} created: #{supplier.name}".green
end

puts "\nCreating storefronts...".yellow.bold
admins.each_with_index do |admin, i|
  2.times do |j|
    storefront = Storefront.create!(
      name: Faker::Company.name,
      user: admin,
      address: Faker::Address.street_address,
      city: Faker::Address.city,
      margin: rand(0.5..0.6)
    )
    puts "  - Storefront ##{i * 2 + j + 1} created: #{storefront.name}".green
  end
end

puts "\nCreating categories...".yellow.bold
categories = ['Electronics', 'Clothing', 'Books', 'Home & Garden', 'Sports'].map.with_index do |name, i|
  category = Category.create!(name: name)
  puts "  - Category ##{i + 1} created: #{category.name}".green
  category
end

puts "\nCreating products and stocks...".yellow.bold
Storefront.all.each_with_index do |storefront, i|
  rand(5..10).times do |j|
    cost = Faker::Commerce.price(range: 10.0..100.0)
    price = (cost * (1 + storefront.margin)).round(2)
    product = Product.create!(
      name: Faker::Commerce.product_name,
      price: price,
      cost: cost,
      quantity: rand(0..100),
      category: categories.sample,
      storefront: storefront
    )
    Stock.create!(
      product: product,
      quantity: rand(10..100),
      last_updated_at: Faker::Time.between(from: 1.month.ago, to: Time.current)
    )
    puts "  - Product ##{i + j + 1} created: #{product.name} ($#{product.price})".green
  end
end

puts "\nCreating restocks...".yellow.bold
Product.all.each_with_index do |product, i|
  rand(1..3).times do |j|
    Restock.create!(
      product: product,
      supplier: Supplier.all.sample,
      quantity: rand(10..50),
      restocked_at: Faker::Time.between(from: 6.months.ago, to: Time.current)
    )
    puts "  - Restock for Product ##{i + 1} (#{product.name}) added".green
  end
end

# Discounts
puts "\nCreating discounts...".yellow.bold

Storefront.all.each do |storefront|
  print "  - Creating discount... ".light_red
  discount = Discount.create!(
    code: Faker::Commerce.promotion_code,
    percentage: Faker::Number.between(from: 5, to: 50),
    start_date: Time.now - Faker::Number.between(from: 1, to: 10).days,
    end_date: Time.now + Faker::Number.between(from: 10, to: 30).days,
    storefront_id: storefront.id
  )
  puts "#{discount.code}:#{discount.storefront.name} done!".green
end

puts "\nCreating orders, invoices, and payments...".yellow.bold
customers.each_with_index do |customer, i|
  rand(10..20).times do |j|
    order = Order.create!(
      customer: customer,
      status: %w[pending completed canceled processing].sample,
      total_price: 0
    )

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

    total = order.order_items.sum { |item| item.quantity * item.unit_price }
    order.update!(total_price: total)

    puts "  - Order ##{i * 10 + j + 1} created - #{customer.email} - #{order.status}".green

    if order.status == 'completed'
      invoice = Invoice.create!(
        order: order,
        shipping: customer.shippings.sample,
        status: ['pending', 'paid'].sample,
        total_amount: total,
        due_date: Faker::Time.between(from: Time.current, to: 30.days.from_now)
      )
      puts "    - Invoice created: #{invoice.status} - Amount $#{invoice.total_amount}".blue

      if invoice.status == 'paid'
        Payment.create!(
          invoice: invoice,
          amount: invoice.total_amount,
          payment_date: Faker::Time.between(from: 30.days.ago, to: Time.current),
          payment_method: ['credit_card', 'debit_card', 'bank_transfer'].sample,
          status: :completed
        )
        puts "      - Payment completed - invoice_id ##{invoice.id}".cyan
      end
    end
  end
end

# Order Discounts
puts "\nCreating order discounts...".yellow.bold
Order.all.each do |order|
  print "  - Creating order discount... ".light_red
  OrderDiscount.create!(
    order_id: Order.all.sample.id,
    discount_id: Discount.all.sample.id
  )
  puts "done!".green
end

puts "\nSeeding completed successfully!".green.bold
