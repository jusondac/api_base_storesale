# app/services/restock_service.rb
class RestockService
  def self.create_restock(product_id, supplier_id, quantity)
    ActiveRecord::Base.transaction do
      Restock.create!(
        product_id: product_id,
        supplier_id: supplier_id,
        quantity: quantity,
        restocked_at: Time.current
      )
      StockService.update_stock(product_id, quantity)
    end
  rescue => e
    raise "Failed to restock: #{e.message}"
  end
end
