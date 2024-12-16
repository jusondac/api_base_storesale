class OrderCreator
  class OrderCreationError < StandardError; end
  class InsufficientStockError < StandardError; end
  class ProductUpdateError < StandardError; end
  class ShippingError < StandardError; end

  # @param customer [Customer] the customer creating the order
  # @param items [Array<Hash>] array of items with :product_id, :quantity, and :unit_price
  # @return [Order] the created order
  # @raise [OrderCreationError] if order creation fails
  def self.create_order(customer:, items:, shipping:)
    raise OrderCreationError, "Couldn't find Customer" if customer.nil?
    raise OrderCreationError, "User must be a customer" unless customer.customer?
    new.create_order(customer: customer, items: items, shipping: shipping)
  end

  # @param product_id [Integer] the ID of the product to update
  # @param name [String, nil] new product name
  # @param price [Decimal, nil] new product price
  # @param quantity [Integer, nil] new product quantity
  # @param category_id [Integer, nil] new category ID
  # @return [Product] the updated product
  # @raise [ProductUpdateError] if update fails
  def self.update_product(product_id:, **attributes)
    new.update_product(product_id: product_id, **attributes)
  end

  def create_order(customer:, items:, shipping:)
    ActiveRecord::Base.transaction do
      order = create_order_record(customer, items)
      create_invoice(order, shipping)
      process_items(order, items)
      order
    end
  rescue => e
    Rails.logger.error("Order creation failed: #{e.message}")
    raise OrderCreationError, e.message
  end

  def update_product(product_id:, **attributes)
    ActiveRecord::Base.transaction do
      product = update_product_attributes(product_id, attributes)
      update_stock_quantity(product.id, attributes[:quantity]) if attributes[:quantity]
      product
    end
  rescue => e
    raise ProductUpdateError, "Failed to update product and stock: #{e.message}"
  end

  private

  def create_order_record(customer, items)
    Order.create!(
      customer: customer,
      total_price: calculate_total_price(items),
      status: 'pending'
    )
  end

  def calculate_total_price(items)
    items.sum { |item| item[:quantity] * item[:unit_price] }
  end

  def create_invoice(order, shipping)
    InvoiceService.create_invoice(order, shipping) || raise(OrderCreationError, "Unable to create invoice")
  end

  def process_items(order, items)
    items.each do |item|
      process_single_item(order, item)
    end
  end

  def process_single_item(order, item)
    Product.transaction do
      product = Product.lock.find(item[:product_id])
      ensure_sufficient_stock(product, item[:quantity])
      create_order_item(order, product, item)
      deduct_stock(product, item[:quantity])
    end
  end

  def ensure_sufficient_stock(product, quantity)
    return if product.stock.quantity >= quantity
    
    raise InsufficientStockError, 
          "Insufficient stock for #{product.name} (requested: #{quantity}, available: #{product.stock.quantity})"
  end

  def create_order_item(order, product, item)
    OrderItem.create!(
      order: order,
      product: product,
      quantity: item[:quantity],
      unit_price: item[:unit_price]
    )
  end

  def deduct_stock(product, quantity)
    product.quantity -= quantity
    product.stock.quantity -= quantity
    
    product.save!
    product.stock.save!
  end

  def update_product_attributes(product_id, attributes)
    product = Product.find(product_id)
    product.assign_attributes(attributes.compact)
    
    unless product.save
      raise ProductUpdateError, product.errors.full_messages.join(", ")
    end
    
    product
  end

  def update_stock_quantity(product_id, quantity)
    stock = Stock.find_by!(product_id: product_id)
    stock.update!(
      quantity: quantity,
      last_updated_at: Time.current
    )
  end
end