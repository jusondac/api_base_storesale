class OrderCreator
  # create order
  def self.create_order(customer:, items:)
    ActiveRecord::Base.transaction do
      # start crafting the order
      order = create_order_record(customer, items)
      # create invoice after order created
      InvoiceService.create_invoice(order) || raise("Unable to create invoice")
      # process items
      process_items(order, items)
      order
    end
  rescue => e
    Rails.logger.error "Order creation failed: #{e.message}"
    raise e
  end

  def self.update_product(product_id:, name: nil, price: nil, quantity: nil, category_id: nil)
    # update product and stock in a single transaction
    ActiveRecord::Base.transaction do
      # update product attributes
      product = update_product_attributes(product_id, name, price, quantity, category_id)
      # update stock quantity
      update_stock_quantity(product.id, quantity) if quantity
      product
    end
  rescue => e
    raise "Failed to update product and stock: #{e.message}"
  end

  private

  def self.create_order_record(customer, items)
    # calculate total price
    total_price = items.sum { |item| item[:quantity] * item[:unit_price] }
    # create order into database
    Order.create!(customer: customer, total_price: total_price, status: 'pending')
  end

  def self.process_items(order, items)
    # process each item in the order 
    items.each do |item|
      product = Product.find(item[:product_id])
      # check if stock is sufficient for the item
      ensure_sufficient_stock(product, item[:quantity])
      # create order item after stock is sufficient
      create_order_item(order, product, item)
      # deduct stock after order item created
      deduct_stock(product, item[:quantity])
    end
  end

  def self.ensure_sufficient_stock(product, quantity)
    # raise error if stock is insufficient
    raise "Insufficient stock for #{product.name}" if product.stock.quantity < quantity
  end

  def self.create_order_item(order, product, item)
    # create order item
    OrderItem.create!(
      order: order,
      product: product,
      quantity: item[:quantity],
      unit_price: item[:unit_price]
    )
  end

  def self.deduct_stock(product, quantity)
    # deduct stock after order item created
    product.update!(quantity: product.quantity - quantity)
    product.stock.update!(quantity: product.stock.quantity - quantity)
  end

  def self.update_product_attributes(product_id, name, price, quantity, category_id)
    # update product attributes in database
    product = Product.find(product_id)
    # assign attributes to product
    product.assign_attributes(
      name: name || product.name,
      price: price || product.price,
      quantity: quantity || product.quantity,
      category_id: category_id || product.category_id
    )
    # save product
    raise product.errors.full_messages.join(", ") unless product.save
    # return updated product
    product
  end

  def self.update_stock_quantity(product_id, quantity)
    # update stock quantity in database
    stock = Stock.find_by(product_id: product_id)
    raise "Stock not found for product ID #{product_id}" unless stock

    stock.update!(quantity: quantity, last_updated_at: Time.current)
  end
end
