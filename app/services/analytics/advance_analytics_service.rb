class Analytics::AdvanceAnalyticsService
  # this service is responsible for providing advanced analytics
  # Sample parameters for start_date, end_date, and storefront
  # {
  #   "start_date": "2023-01-01",
  #   "end_date": "2023-12-31",
  #   "storefront": 1
  # }
  def initialize(start_date: nil, end_date: nil, storefront: nil)
    @start_date = start_date
    @end_date = end_date
    @storefront = storefront
  end

  def profit_margin
    revenue = orders.sum(:total_price)
    costs = orders.joins(:order_items).includes(order_items: :product).reduce(0) do |sum, order|
      sum + order.order_items.reduce(0) do |item_sum, item|
      item_sum + (item.quantity * item.product.price)
      end
    end
    revenue - costs
  end

  def total_revenue
    scope = orders.sum(:total_price)
    scope
  end
  

  def sales_per_category
    Category.joins(products: { order_items: :order })
            .where(orders: { status: 'completed' })
            .select('categories.name, SUM(order_items.quantity * order_items.unit_price) as revenue')
            .group('categories.id')
            .order('revenue DESC')
  end

  def average_order_value
    orders = Order.where(status: 'completed')
    total_revenue = orders.sum(:total_price)
    total_orders = orders.count
    total_orders.zero? ? 0 : (total_revenue / total_orders).round(2)
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
