class Api::V2::Analytics::AdvanceAnalyticsController < ApplicationController
  def index
    analytics = Analytics::AdvanceAnalyticsService.new(start_date: params[:start_date], end_date: params[:end_date])
    render json: {
      profit_margin: analytics.profit_margin,
      sales_per_category: analytics.sales_per_category,
      average_order_value: analytics.average_order_value
    }, status: :ok
  end
end
