class OrderCreator
    def self.create_order(customer:, items:)
      ActiveRecord::Base.transaction do
        # Calculate total price
        total_price = items.sum { |item| item[:quantity] * item[:unit_price] }
  
        # Create the order
        order = Order.create!(customer: customer, total_price: total_price, status: 'Pending')
  
        # Add items to the order
        items.each do |item|
          product = Product.find(item[:product_id])
  
          # Ensure sufficient stock
          raise "Insufficient stock for #{product.name}" if product.stock.quantity < item[:quantity]
  
          # Create order item
          OrderItem.create!(
            order: order,
            product: product,
            quantity: item[:quantity],
            unit_price: item[:unit_price]
          )
  
          # Deduct stock
          product.update!(quantity: product.quantity - item[:quantity])
          product.stock.update!(quantity: product.stock.quantity - item[:quantity])
        end
  
        order
      end
    rescue => e
      Rails.logger.error "Order creation failed: #{e.message}"
      raise e
    end
  end
  