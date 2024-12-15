require 'rails_helper'
require 'faker'

RSpec.describe 'Customers API', type: :request do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{token}" } }
  let!(:customer) { create(:customer, name: 'John Doe', email: 'john@example.com') }

  describe 'GET /customers' do
    it 'returns all customers' do
      get '/api/v1/customers', headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(Customer.count)
    end
  end

  describe 'POST /customers' do
    let(:valid_attributes) { { name: 'Jane Doe', email: 'jane@example.com', phone: '1234567890'} }

    context 'when the request is valid' do
      it 'creates a customer' do
        post '/api/v1/customers', params: valid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['name']).to eq('Jane Doe')
      end
    end

    context 'when the request is invalid' do
      let(:invalid_attributes) { { name: '', email: '' } }

      it 'returns a validation error' do
        post '/api/v1/customers', params: invalid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Name can't be blank")
      end
    end
  end

  describe 'DELETE /customers/:id' do
    it 'deletes the customer' do
      expect {
        delete "/api/v1/customers/#{customer.id}", headers: headers
      }.to change(Customer, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
