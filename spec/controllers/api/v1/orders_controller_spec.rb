require 'rails_helper'

RSpec.describe 'Orders API', type: :request do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{token}" } }
  
  let(:product) { create(:product, price: 100) }
  let!(:stock) { create(:stock, product: product, quantity: 100, last_updated_at: 1.day.ago) }
  let!(:customer) { create(:customer, name: 'John Doe', email: 'john@example.com') }
  let!(:shipping) { create(:shipping, customer: customer) }
  let!(:order) { create(:order, customer: customer) }


  describe 'GET /orders' do
    it 'returns all orders' do
      get '/api/v1/orders', headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(Order.count)
    end
    it 'Unauhorize' do
      get '/api/v1/orders'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /orders/:id' do
    context 'when the order exists' do
      it 'returns the order' do
        get "/api/v1/orders/#{order.id}", headers: headers
        expect(response).to have_http_status(:ok)
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

  describe 'POST /api/v1/orders' do
    context 'when the order is valid' do

      let(:valid_order) do
        {
          order: {
            customer_id: customer.id,
            status: "pending",
            order_items: [
              { product_id: product.id, quantity: 2 }
            ],
            shipping_id: shipping.id
          }
        }
      end

      it 'creates an order successfully' do
        post '/api/v1/orders', params: valid_order.to_json, headers: headers
        expect(response).to have_http_status(:created)
        response_body = JSON.parse(response.body)
        expect(response_body['customer_id']).to eq(customer.id)
      end
    end

    context 'when order items are empty' do
      let(:invalid_order) do
        {
          order: {
            customer_id: customer.id,
            status: "pending",
            order_items: []
          }
        }
      end

      it 'returns an error message for empty order items' do
        post '/api/v1/orders', params: invalid_order.to_json, headers: headers

        response_body = JSON.parse(response.body)
        expect(response_body['status']).to eq("unprocessable_entity")
        expect(response_body['error']).to eq("Really fuckers? u didn't buy anythin?")
      end
    end

    context 'when order items are missing' do
      let(:missing_items_order) do
        {
          order: {
            customer_id: customer.id
          }
        }
      end

      it 'returns an error message for missing order items' do
        post '/api/v1/orders', params: missing_items_order.to_json, headers: headers
        response_body = JSON.parse(response.body)
        expect(response_body['status']).to eq("unprocessable_entity")
        expect(response_body['error']).to eq("Really fuckers? u didn't buy anythin?")
      end
    end

    context 'when an exception occurs' do
      let(:invalid_customer_order) do
        {
          order: {
            customer_id: 999, # Invalid customer ID
            order_items: [
              { product_id: product.id, quantity: 2 }
            ]
          }
        }
      end

      it 'returns an error message for an exception' do
        post '/api/v1/orders', params: invalid_customer_order.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to match(/Couldn't find Customer/)
      end
    end
  end
end
