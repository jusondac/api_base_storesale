class Api::V1::CustomersController < ApplicationController
  def index
    @customers = User.customers
    render json: @customers
  end

  def show
    @customer = User.find(params[:id])
    render json: @customer
  end

  def order_customer
    @customer = User.find(params[:id])
    @orders = @customer.orders
    render json: { customer: @customer, orders: @orders }
  end

  def new
    @customer = User.new
    render json: @customer
  end

  def create
    @customer = User.new(customer_params)
    if @customer.save
      render json: @customer, status: :created
    else
      render json: { errors: @customer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def edit
    @customer = User.find(params[:id])
    render json: { customer: @customer, categories: @categories }
  end

  def update
    @customer = User.find(params[:id])
    if @customer.update(customer_params)
      render json: @customer, status: :ok
    else
      render json: { errors: @customer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @customer = User.find(params[:id])
    @customer.destroy
    render json: { message: 'User deleted successfully' }, status: :no_content
  end

  private

  def customer_params
    params.require(:customer).permit(:name, :email, :phone)
  end
end
  