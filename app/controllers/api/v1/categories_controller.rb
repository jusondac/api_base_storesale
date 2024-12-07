module Api
  module V1
    class CategoriesController < ApplicationController
      def index
        @categories = Category.all
        render json: @categories
      end

      def show
        @category = Category.find(params[:id])
        render json: @category
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

      def edit
        @category = Category.find(params[:id])
        render json: { category: @category, categories: @categories }
      end

      def update
        @category = Category.find(params[:id])
        if @category.update(category_params)
          render json: @category, status: :ok
        else
          render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @category = Category.find(params[:id])
        @category.destroy
        render json: { message: 'Category deleted successfully' }, status: :no_content
      end

      private

      def category_params
        params.require(:category).permit(:name)
      end
    end
  end
end
