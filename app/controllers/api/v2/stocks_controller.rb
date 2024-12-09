class Api::V2::StocksController < ApplicationController
  def index
    stocks = Stock.includes(:product)
    render json: stocks, includes: :product, status: :ok
  end

  def show
    stock = Stock.find_by(id: params[:id])
    return render json: { error: "this mf Stock not found you idiot!" }, status: :not_found unless stock

    render json: stock, include: :product, status: :ok
  end

  def update
    stock = StockService.update_stock(stock_id: params[:id], quantity: stock_params[:quantity])
    return render json: { error: "Told you, its not found dumbass" }, status: :not_found unless stock

    if stock.update(stock_params)
      render json: stock, status: :ok
    else
      render json: { errors: stock.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def stock_params
    params.require(:stock).permit(:quantity, :last_updated_at)
  end
end
