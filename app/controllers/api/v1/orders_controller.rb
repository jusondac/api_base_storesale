module Api
    module V1
      class OrdersController < ApplicationController
        def index
          @orders = Order.includes(:customer).all
          render json: @orders, include: :customer
        end
  
        def show
          @order = Order.includes(:order_items, :products).find(params[:id])
          @order = @order.as_json(
            include: {
              customer: { only: [:name, :email] },
              order_items: {
                except: [:created_at, :updated_at, :order_id, :product_id, :id],
                include: {
                  product: { except: [:created_at, :updated_at, :category_id, :id] }
                }
              }
            }
          )
          render json: @order, status: :ok
        end
  
        def new
          @order = Order.new
          @customers = Customer.select(:id, :name, :email)
          @products = Product.select(:id, :name, :price)
          render json: { order: @order, customers: @customers, products: @products }
        end
  
        def create
          return render json: { error: "Really fuckers? u didn't buy anythin?", status: :unprocessable_entity } if (order_params[:order_items].nil? || order_params[:order_items].empty?)
          items = order_params[:order_items].map do |item|
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
          params.require(:order).permit(:customer_id, :status, order_items: [:product_id, :quantity])
        end
      end
    end
  end
  