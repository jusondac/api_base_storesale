require 'rails_helper'

RSpec.describe 'Products API', type: :request do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{token}" } }
  let!(:product) { create(:product, price: 100) }
  let!(:storefront) { create(:storefront, user: user) }
  let!(:category) { create(:category, name: 'Home Tools') }
  let(:valid_attributes) { {name: "Laptop", category_id: category.id, storefront_id: storefront.id, quantity: 200, price: 200.00 } }
  let(:invalid_attributes) { {name: nil, category_id: category.id, storefront_id:storefront.id, quantity: 200, price: 200.00 } }
  let(:miss_storefront_attributes) { {name: "Laptop", category_id: category.id, storefront_id:nil, quantity: 200, price: 200.00 } }

  describe 'GET /api/v1/products' do
    it 'returns all products' do
      get '/api/v1/products', headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(Product.count)
    end
  end

  describe 'GET /api/v1/products/:id' do
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

  describe 'POST /api/v1/products/' do
    context 'when valid parameters are provided' do
      it 'creates a product and initializes stock' do
        post "/api/v1/products", params: valid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:created)
        product = JSON.parse(response.body)
        stock = Stock.find_by(product_id: product['id'])
        expect(product['name']).to eq('Laptop')
        expect(product['price']).to eq(200.00)
        expect(product['quantity']).to eq(200)
        expect(product['category_id']).to eq(category.id)
        expect(product['storefront_id']).to eq(storefront.id)
        expect(stock.quantity).to eq(200)
      end
    end

    context 'when invalid parameters are provided' do
      it 'raises an error if the product cannot be saved' do
        post "/api/v1/products", params: invalid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq("Failed to create product and stock: Name can't be blank")
      end

      it 'raises an error if storefront is not exist' do
        post "/api/v1/products", params: miss_storefront_attributes.to_json, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq("Failed to create product and stock: Storefront must exist")
      end

      it 'raises an error if stock cannot be initialized' do
        allow_any_instance_of(Stock).to receive(:save).and_return(false) # Simulate stock save failure

        expect {
          ProductService.create_product(
            name: "Laptop",
            price: 1500.00,
            quantity: 10,
            category_id: category.id,
            storefront_id: storefront.id
          )
        }.to raise_error(/Failed to create product and stock/)
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
