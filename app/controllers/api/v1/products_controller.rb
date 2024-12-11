module Api
  module V1
    class ProductsController < ApplicationController
      def index
        @products = Product.includes(:category).all
        render json: @products, include: :category
      end

      def show
        @product = Product.find(params[:id])
        render json: @product, include: :category
      end

      def new
        @product = Product.new
        @categories = Category.all
        render json: { product: @product, categories: @categories }
      end

      def create
        product = ProductService.create_product(
          name: product_params[:name],
          price: product_params[:price],
          quantity: product_params[:quantity],
          category_id: product_params[:category_id],
          storefront_id: product_params[:storefront_id]
        )
        render json: product, status: :created
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def edit
        @product = Product.find(params[:id])
        @categories = Category.all
        render json: { product: @product, categories: @categories }
      end

      def update
        @product = Product.find(params[:id])
        if @product.update(product_params)
          render json: @product, status: :ok
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end
      

      def destroy
        @product = Product.find(params[:id])
        @product.destroy
        render json: { message: 'Product deleted successfully' }, status: :no_content
      end

      private

      def product_params
        params.require(:product).permit(:name, :price, :quantity, :category_id, :storefront_id)
      end
    end
  end
end
