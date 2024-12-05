require 'rails_helper'

RSpec.describe Api::V1::ProductsController, type: :controller do
  let!(:category) { create(:category) }
  let!(:product) { create(:product, category: category) }

  describe 'GET #index' do
    it 'returns a list of products' do
      get :index
      expect(response).to have_http_status(:success)
      expect(response.body).to include(product.name)
    end
  end

  describe 'GET #show' do
    it 'returns a product' do
      get :show, params: { id: product.id }
      expect(response).to have_http_status(:success)
      expect(response.body).to include(product.name)
    end
  end

  describe 'POST #create' do
    it 'creates a new product' do
      product_params = { name: 'New Product', price: 99.99, quantity: 10, category_id: category.id }
      post :create, params: { product: product_params }
      Rails.logger.debug("Response body: #{response.body}")
      expect(response).to have_http_status(:created)
      expect(Product.last.name).to eq('New Product')
    end
  end

  describe 'PUT #update' do
    it 'updates an existing product' do
      updated_name = 'Updated Product'
      put :update, params: { id: product.id, product: { name: updated_name } }
      Rails.logger.debug("Response body: #{response.body}")
      expect(response).to have_http_status(:ok)
      expect(product.reload.name).to eq(updated_name)
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes a product' do
      delete :destroy, params: { id: product.id }
      Rails.logger.debug("Response body: #{response.body}")
      expect(response).to have_http_status(:no_content)
      expect(Product.exists?(product.id)).to be_falsey
    end
  end
end
