require 'rails_helper'

RSpec.describe 'Orders API', type: :request do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{token}" } }

  # Assuming an Order belongs to a Customer and has multiple Products
  let!(:customer) { create(:customer, name: 'John Doe', email: 'john@example.com') }
  let!(:product1) { create(:product, name: 'Product 1', price: 100, quantity: 10) }
  let!(:product2) { create(:product, name: 'Product 2', price: 200, quantity: 5) }
  let!(:order) { create(:order, customer: customer, status: 'pending') }

  describe 'GET /orders' do
    it 'returns all orders' do
      get '/api/v1/orders', headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(Order.count)
    end
  end

  describe 'GET /orders/:id' do
    context 'when the order exists' do
      it 'returns the order' do
        get "/api/v1/orders/#{order.id}", headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']).to eq('pending')
      end
    end

    context 'when the order does not exist' do
      it 'returns a not found message' do
        get '/api/v1/orders/999', headers: headers
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq("Order not found")
      end
    end
  end

  describe 'POST /orders' do
    # let(:valid_attributes) { { customer_id: customer.id, status: 'confirmed', product_ids: [product1.id, product2.id] } }
    let(:valid_attributes) { { 
      order_items: {customer_id: customer.id, status: 'confirmed', product_ids: [product1.id, product2.id]}
     } }
    let(:invalid_attributes) { { customer_id: nil, status: '' } }

    context 'when the request is valid' do
      it 'creates an order' do
        post '/api/v1/orders', params: valid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['status']).to eq('confirmed')
      end
    end

    context 'when the request is invalid' do
      it 'returns a validation error' do
        post '/api/v1/orders', params: invalid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Customer can't be blank")
      end
    end
  end

  describe 'PUT /orders/:id' do
    let(:valid_attributes) { { status: 'shipped' } }

    context 'when the order exists' do
      it 'updates the order' do
        put "/api/v1/orders/#{order.id}", params: valid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']).to eq('shipped')
      end
    end

    context 'when the order does not exist' do
      it 'returns a not found message' do
        put '/api/v1/orders/999', params: valid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq("Order not found")
      end
    end
  end

  describe 'DELETE /orders/:id' do
    context 'when the order exists' do
      it 'deletes the order' do
        expect {
          delete "/api/v1/orders/#{order.id}", headers: headers
        }.to change(Order, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when the order does not exist' do
      it 'returns a not found message' do
        delete '/api/v1/orders/999', headers: headers
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq("Order not found")
      end
    end
  end
end
