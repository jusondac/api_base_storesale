module Api
    module V1
      class OrdersController < ApplicationController
        def index
          @orders = Order.includes(:customer).all
          render json: @orders, include: :customer
        end
  
        def show
          @order = Order.includes(:order_items, :products).find(params[:id])
          render json: @order, include: { order_items: { include: :product } }
        end
  
        def new
          @order = Order.new
          @customers = Customer.all
          @products = Product.all
          render json: { order: @order, customers: @customers, products: @products }
        end
  
        def create
          items = params[:order_items].map do |item|
            {
              product_id: item[:product_id],
              quantity: item[:quantity],
              unit_price: Product.find(item[:product_id]).price
            }
          end
          customer = Customer.find(order_params[:customer_id])
          @order = OrderCreator.create_order(customer: customer, items: items)
          render json: @order, status: :created
        rescue => e
          render json: { errors: e.message }, status: :unprocessable_entity
        end
  
        private
  
        def order_params
          params.require(:order).permit(:customer_id, :total_price, :status)
        end
      end
    end
  end
  