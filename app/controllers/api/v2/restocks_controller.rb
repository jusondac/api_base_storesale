class Api::V2::RestocksController < ApplicationController
  def index
    restock = Restock.all
    render json: restock, status: :ok
  end

  def create
    restock = Restock.new(restock_params)
    if restock.save
      render json: restock, status: :created
    else
      render json: { errors: restock.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    restock = Restock.find(params[:id])
    render json: restock, status: :ok
  end
  

  private

  def restock_params
    params.require(:restock).permit(:product_id, :quantity, :restocked_at, :supplier_id)
  end
end
