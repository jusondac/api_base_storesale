require 'rails_helper'

RSpec.describe 'Api::V1::Products', type: :request do
  let(:user) { create(:user) } # Creates a user with a valid JWT
  let(:token) { JsonWebToken.encode(user_id: user.id) } # Encodes the token for authorization
  let(:headers) { { Authorization: "Bearer #{token}" } } # Authorization header with the token

  let!(:category) { create(:category) } # Create a category
  let!(:products) { create_list(:product, 5, category: category) } # Create 5 products linked to the category
  let(:product_id) { products.first.id } # Get the ID of the first product

  describe 'GET /products' do
    context 'when the user is authenticated' do
      it 'returns a list of products' do
        get '/api/v1/products', headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(5)
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized error' do
        get '/api/v1/products'
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
      end
    end
  end

  describe 'GET /products/:id' do
    context 'when the product exists' do
      it 'returns the product' do
        get "/api/v1/products/#{product_id}", headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['id']).to eq(product_id)
      end
    end

    context 'when the product does not exist' do
      it 'returns a not found message' do
        get '/api/v1/products/9999', headers: headers
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq("Product not found")
      end
    end
  end

  describe 'POST /products' do
    let(:valid_attributes) {   { 
      product: { name: 'New Product', quantity: 10, price: 100.0, category_id: category.id } 
    } }

    context 'when the request is valid' do
      it 'creates a new product' do
        post '/api/v1/products', params: valid_attributes, headers: headers
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['name']).to eq('New Product')
      end
    end

    context 'when the request is invalid' do
      it 'returns a validation error' do
        post '/api/v1/products', params: { product: { name: '' } }, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Name can't be blank")
      end
    end
  end

  describe 'PUT /products/:id' do
    let(:valid_attributes) { { 
      product: { name: 'Updated Product', quantity: 10, price: 100.0, category_id: category.id } 
     } }

    context 'when the product exists' do
      it 'updates the product' do
        put "/api/v1/products/#{product_id}", params: valid_attributes, headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['name']).to eq('Updated Product')
      end
    end

    context 'when the product does not exist' do
      it 'returns a not found message' do
        put '/api/v1/products/9999', params: valid_attributes, headers: headers
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq("Product not found")
      end
    end
  end

  describe 'DELETE /products/:id' do
    context 'when the product exists' do
      it 'deletes the product' do
        delete "/api/v1/products/#{product_id}", headers: headers
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when the product does not exist' do
      it 'returns a not found message' do
        delete '/api/v1/products/9999', headers: headers
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq("Product not found")
      end
    end
  end
end
