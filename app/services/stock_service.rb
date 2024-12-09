# app/services/stock_service.rb
class StockService
  def self.update_stock(stock_id:, quantity:)
    ActiveRecord::Base.transaction do
      stock = Stock.find(stock_id)
      raise "Stock not found for ID #{stock_id}" unless stock

      stock.quantity += quantity
      stock.last_updated_at = Time.current
  
      if stock.save
        stock
      else
        raise stock.errors.full_messages.join(", ")
      end
    end
  end
end
