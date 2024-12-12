class SalesAnalyticsService
  def initialize(start_date: nil, end_date: nil, storefront: nil)
    @start_date = start_date
    @end_date = end_date
    @storefront = storefront
  end

  def total_revenue
    orders.sum(:total_price)
  end

  def best_selling_products(limit: 5)
    OrderItem.joins(:product)
             .select('products.name, SUM(order_items.quantity) as total_quantity')
             .group('products.name')
             .order('total_quantity DESC')
             .limit(limit)
  end

  def customer_lifetime_value
    Customer.joins(:orders)
            .select('customers.name, SUM(orders.total_price) as lifetime_value')
            .group('customers.id')
            .order('lifetime_value DESC')
  end

  def sales_by_period(interval: 'day')
    case interval
    when 'day'
      orders.group("DATE(created_at)").sum(:total_price).map do |date, total_price|
        { 'date' => date, 'total_price' => total_price }
      end
    when 'month'
      orders.group("strftime('%Y-%m', created_at)").sum(:total_price).map do |date, total_price|
        { 'month' => date, 'total_price' => total_price }
      end
    when 'year'
      orders.group("strftime('%Y', created_at)").sum(:total_price).map do |date, total_price|
        { 'year' => date, 'total_price' => total_price }
      end
    else
      raise ArgumentError, "Invalid interval: #{interval}. Use 'day', 'month', or 'year'."
    end
  end
  

  def storefront_performance
    Storefront.joins(products: { order_items: :order })
              .select('storefronts.name, SUM(orders.total_price) as total_revenue, COUNT(orders.id) as total_orders')
              .group('storefronts.id')
              .order('total_revenue DESC')
  end

  private

  def orders
    scope = Order.where(status: 'completed')
    scope = scope.where('created_at >= ?', @start_date) if @start_date
    scope = scope.where('created_at <= ?', @end_date) if @end_date
    scope = scope.joins(:products).where(products: { storefront_id: @storefront.id }) if @storefront
    scope
  end
end
