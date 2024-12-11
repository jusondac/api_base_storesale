require 'rails_helper'

RSpec.describe "Restocks API", type: :request do
  let(:user) { create(:user) } # Assuming a user factory exists
  let(:auth_token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { "Authorization" => "Bearer #{auth_token}", "Content-Type" => "application/json" } }

  let(:supplier) { create(:supplier) }
  let(:product) { create(:product) }
  let(:restock) { create(:restock, supplier: supplier) }
  let(:valid_params) { { product_id: product.id, quantity: 100, restock_at: Time.current, supplier_id: supplier.id } }
  let(:invalid_params) { { product_id: product.id, quantity: nil, restock_at: Time.current, supplier_id: supplier.id } }
  let(:invalid_params_wo_supplier_id) { { product_id: product.id, quantity: 100, restock_at: Time.current, supplier_id: nil } }

  describe 'GET /api/v2/restocks' do
    it 'returns all restocks' do
      get '/api/v2/restocks', headers: headers
      expect(response).to have_http_status(:ok)
    end

    it 'return not authorize' do
      get '/api/v2/restocks'
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
    end
  end

  describe 'POST /api/v2/restocks' do
    it 'create restock' do
      post '/api/v2/restocks', params: valid_params.to_json, headers: headers
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['product_id']).to eq(product.id)
    end

    it 'return quantity is not a number' do
      post '/api/v2/restocks', params: invalid_params.to_json, headers: headers
      expect(response).to have_http_status(:unprocessable_entity) 
      expect(JSON.parse(response.body)['errors']).to include("Quantity is not a number")
    end
    
    it 'return supplier_id is must exist' do
      post '/api/v2/restocks', params: invalid_params_wo_supplier_id.to_json, headers: headers
      expect(response).to have_http_status(:unprocessable_entity) 
      expect(JSON.parse(response.body)['errors']).to include("Supplier must exist")
    end
  end

  describe 'POST /api/v2/restocks' do
    it 'Show Restock restock' do
      get "/api/v2/restocks/#{restock.id}", params: valid_params.to_json, headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['supplier_id']).to eq(supplier.id)
    end
  end
  
end
