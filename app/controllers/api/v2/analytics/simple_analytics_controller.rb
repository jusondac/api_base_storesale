class Api::V2::Analytics::SimpleAnalyticsController < ApplicationController
  def index
    analytics = Analytics::SalesAnalyticsService.new(start_date: params[:start_date], end_date: params[:end_date])
    render json: {
      total_revenue: analytics.total_revenue,
      best_selling_products: analytics.best_selling_products,
      customer_lifetime_value: analytics.customer_lifetime_value,
      sales_by_day: analytics.sales_by_period(interval: 'day'),
      storefront_performance: analytics.storefront_performance
    }, status: :ok
  end
end
