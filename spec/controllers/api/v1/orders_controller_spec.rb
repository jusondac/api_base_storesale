require 'rails_helper'

RSpec.describe Api::V1::OrdersController, type: :controller do
  let!(:customer) { create(:customer) }
  let!(:product) { create(:product) }

  describe 'GET #index' do
    it 'returns a list of orders' do
      get :index
      Rails.logger.debug("Response body: #{response.body}")
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    let!(:order) { create(:order, customer: customer) }
    it 'returns a specific order' do
      get :show, params: { id: order.id }
      Rails.logger.debug("Response body: #{response.body}")
      expect(response).to have_http_status(:success)
    end
  end

  # describe 'POST #create' do
  #   it 'creates a new order with valid parameters' do
  #     order_params = {
  #       order: {
  #         customer_id: customer.id,
  #         order_items: [
  #           { product_id: product.id, quantity: 2 }
  #         ]
  #       }
  #     }

  #     expect {
  #       post :create, params: order_params
  #     }.to change(Order, :count).by(1)

  #     expect(response).to have_http_status(:created)
  #   end
  # end
  
end
