module Api
  module V1
    class CategoriesController < ApplicationController
      def index
        @categories = Category.all
        render json: @categories
      end

      def show
        @category = Category.find(params[:id])
        render json: @category, include: :products
      end

      def new
        @category = Category.new
        render json: @category
      end

      def create
        @category = Category.new(category_params)
        if @category.save
          render json: @category, status: :created
        else
          render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def category_params
        params.require(:category).permit(:name)
      end
    end
  end
end
