require 'rails_helper'

RSpec.describe Api::V1::ProductsController, type: :controller do
  let(:user) { create_user }
  let(:headers) { authenticated_header(user) }
  let!(:product) { Product.create(name: 'Test Product', quantity: 10, price: 100.0) }

  describe 'GET #index' do
    context 'with valid authentication' do
      it 'returns a list of products' do
        request.headers.merge!(headers)
        get :index

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).not_to be_empty
      end
    end

    context 'without authentication' do
      it 'returns unauthorized status' do
        get :index
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET #show' do
    context 'with valid authentication' do
      it 'returns the requested product' do
        request.headers.merge!(headers)
        get :show, params: { id: product.id }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['name']).to eq('Test Product')
      end
    end

    context 'with invalid product ID' do
      it 'returns not found status' do
        request.headers.merge!(headers)
        get :show, params: { id: 0 }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq("Product not found")
      end
    end
  end
end
