require 'rails_helper'

RSpec.describe 'Suppliers API', type: :request do
  let(:user) { create(:user) }
  let(:vendor) { create(:user, role: 3) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{token}" } }

  let(:supplier) { create(:supplier, name: 'Jane Doe', email: 'jane@example.com', phone: '1234567890') }

  describe 'GET /api/v2/suppliers' do
    it 'returns all suppliers' do
      get '/api/v2/suppliers', headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(Supplier.count)
    end

    it 'unauthorize' do
      get '/api/v2/suppliers'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /api/v2/suppliers' do
    let(:valid_attributes) { { name: 'Jane Doe', email: 'jane@example.com', phone: '1234567890', owner_id: vendor.id } }

    context 'when the request is valid' do
      it 'creates a suppliers' do
        post '/api/v2/suppliers', params: valid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['name']).to eq('Jane Doe')
      end
    end

    context 'when the request is invalid' do
      let(:invalid_attributes) { { name: '', email: '' } }

      it 'returns a validation error' do
        post '/api/v2/suppliers', params: invalid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Name can't be blank")
      end
    end
  end

  # describe 'DELETE /customers/:id' do
  #   it 'deletes the customer' do
  #     expect {
  #       delete "/api/v1/customers/#{customer.id}", headers: headers
  #     }.to change(Customer, :count).by(-1)
  #     expect(response).to have_http_status(:no_content)
  #   end
  # end
end
