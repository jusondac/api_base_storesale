class OrderCreator
    def self.create_order(customer:, items:)
      ActiveRecord::Base.transaction do
        # Calculate total price
        total_price = items.sum { |item| item[:quantity] * item[:unit_price] }
        
        # Create the order
        order = Order.create!(customer: customer, total_price: total_price, status: 'pending')
        # Add items to the order
        raise "Unable to create invoice" unless InvoiceService.create_invoice(order)
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

    def self.update_product(product_id:, name: nil, price: nil, quantity: nil, category_id: nil)
      product = Product.find(product_id)
      ActiveRecord::Base.transaction do
        product.assign_attributes(
          name: name || product.name,
          price: price || product.price,
          quantity: quantity || product.quantity,
          category_id: category_id || product.category_id
        )
    
        raise product.errors.full_messages.join(", ") unless product.save
    
        if quantity
          stock = Stock.find_by(product_id: product.id)
          raise "Stock not found for product ID #{product_id}" unless stock
    
          stock.update!(quantity: quantity, last_updated_at: Time.current)
        end
    
        product
      end
    rescue => e
      raise "Failed to update product and stock: #{ e.message }"
    end
  end
  