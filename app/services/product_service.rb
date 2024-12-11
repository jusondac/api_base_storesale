# app/services/product_service.rb
class ProductService
  def self.create_product(name:, price:, quantity:, category_id:, storefront_id:)
    ActiveRecord::Base.transaction do
      # Create the product
      product = Product.new(
        name: name,
        price: price,
        quantity: quantity,
        category_id: category_id,
        storefront_id: storefront_id
      )

      raise product.errors.full_messages.join(", ") unless product.save

      # Initialize the stock
      stock = Stock.new(
        product_id: product.id,
        quantity: quantity,
        last_updated_at: Time.current
      )

      raise stock.errors.full_messages.join(", ") unless stock.save

      product
    end
  rescue => e
    raise "Failed to create product and stock: #{e.message}"
  end

  def self.update_product(product_id:, name: nil, price: nil, quantity: nil, category_id: nil, storefront_id: nil)
    product = Product.find(product_id)
    ActiveRecord::Base.transaction do
      product.assign_attributes(
        name: name.presence || product.name,
        price: price.presence || product.price,
        quantity: quantity.presence || product.quantity,
        category_id: category_id.presence || product.category_id,
        storefront_id: storefront_id.presence || product.storefront_id
      )
      raise product.errors.full_messages.join(", ") unless product.save

      # Update stock if quantity changes
      if quantity.present?
        stock = Stock.find_by(product_id: product.id)
        raise "Stock not found for product ID #{product_id}" unless stock

        stock.quantity = quantity
        stock.last_updated_at = Time.current

        raise stock.errors.full_messages.join(", ") unless stock.save
      end

      product
    end
  rescue => e
    raise "Failed to update product and stock: #{e.message}"
  end
end
