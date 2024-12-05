require 'rails_helper'

RSpec.describe Api::V1::CustomersController, type: :controller do
  let!(:customer) { create(:customer) }

  describe 'GET #index' do
    it 'returns a list of customers' do
      get :index
      Rails.logger.debug("Response body: #{response.body}")
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    it 'returns a specific customer' do
      get :show, params: { id: customer.id }
      Rails.logger.debug("Response body: #{response.body}")
      expect(response).to have_http_status(:success)
      expect(response.body).to include(customer.name)
    end
  end
end
