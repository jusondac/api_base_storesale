class Api::V2::SuppliersController < ApplicationController
  def index
    suppliers = Supplier.all
    render json: suppliers, status: :ok
  end

  def create
    supplier = Supplier.new(supplier_params)

    if supplier.save
      render json: supplier, status: :created
    else
      render json: { errors: supplier.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def supplier_params
    params.require(:supplier).permit(:name, :email, :phone_number, :address)
  end
end
