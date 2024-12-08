require 'rails_helper'

RSpec.describe 'Products API', type: :request do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{token}" } }
  let!(:product) { create(:product, price: 100) }
  let!(:category) { create(:category, name: 'lol') }

  describe 'GET /products' do
    it 'returns all products' do
      get '/api/v1/products', headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(Product.count)
    end
  end

  describe 'GET /products/:id' do
    context 'when the product exists' do
      it 'returns the product' do
        get "/api/v1/products/#{product.id}", headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['price']).to eq(product.price)
        expect(JSON.parse(response.body)['name']).to eq(product.name)
      end
    end

    context 'when the product does not exist' do
      it 'returns a not found message' do
        get '/api/v1/products/999', headers: headers
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq("Product not found")
      end
    end
  end

  describe 'POST /products' do
    let(:valid_attributes) { { name: 'Furniture', price: 100, quantity: 100, category_id: category.id } }
    let(:invalid_attributes) { { name: '', price: 100, quantity: 100, category_id: category.id } }

    context 'when the request is valid' do
      it 'creates a product' do
        post '/api/v1/products', params: valid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:created)
        response_body = JSON.parse(response.body)
        expect(response_body['name']).to eq('Furniture')
      end
    end

    context 'when the request is invalid' do
      it 'returns a validation error' do
        post '/api/v1/products', params: invalid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Name can't be blank")
      end
    end
  end

  describe 'PUT /products/:id' do
    let(:valid_attributes) { { 
      product: {name: 'Home Appliances'}
     } }

    context 'when the product exists' do
      it 'updates the product' do
        put "/api/v1/products/#{product.id}", params: valid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['name']).to eq('Home Appliances')
      end
    end

    context 'when the product does not exist' do
      it 'returns a not found message' do
        put '/api/v1/products/999', params: valid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq("Product not found")
      end
    end
  end

  describe 'DELETE /products/:id' do
    context 'when the product exists' do
      it 'deletes the product' do
        expect {
          delete "/api/v1/products/#{product.id}", headers: headers
        }.to change(Product, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when the product does not exist' do
      it 'returns a not found message' do
        delete '/api/v1/products/999', headers: headers
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq("Product not found")
      end
    end
  end
end
