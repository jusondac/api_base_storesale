require 'rails_helper'

RSpec.describe 'Storefronts API', type: :request do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{token}" } }
  let!(:storefront) { create(:storefront, user: user ) }
  let(:valid_attributes) { { name: "Storefront Sejahtera", user_id: user.id, city: "Jakarta", address: "123 Main St" } }
  let(:invalid_attributes) { {name: nil, user_id: user.id, city: "Jakarta", address: "123 Main St" } }
  let(:no_user_attributes) { {name: "Storefront Sejahtera", city: "Jakarta", address: "123 Main St" } }

  describe 'GET /api/v2/storefronts' do 
    it 'returns all storefronts' do
      get '/api/v2/storefronts', headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(Storefront.count)
    end

    it 'unauthorized user' do
      get '/api/v2/storefronts'
      expect(response).to have_http_status(:unauthorized)
    end
  end
  
  describe 'GET /api/v2/storefronts/:id' do
    it 'returns a storefront' do
      get "/api/v2/storefronts/#{storefront.id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['name']).to eq(storefront.name)
    end

    it 'raises an error if the storefront cannot be found' do
      get '/api/v2/storefronts/0', headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v2/storefronts' do
    context 'when valid parameters are provided' do
      it 'creates a storefront' do
        post '/api/v2/storefronts', params: valid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['name']).to eq('Storefront Sejahtera')
      end
    end

    context 'when invalid parameters are provided' do
      it 'raises an error if the storefront cannot be saved' do
        post '/api/v2/storefronts', params: invalid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end


  describe 'PUT /api/v2/storefronts/:id' do
    it 'updates a storefront' do
      put "/api/v2/storefronts/#{storefront.id}", params: { name: "Storefront Baru" }.to_json, headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['name']).to eq('Storefront Baru')
    end

    it 'raises an error if the storefront cannot be updated' do
      put "/api/v2/storefronts/#{storefront.id}", params: invalid_attributes.to_json, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/v2/storefronts/:id' do
    it 'deletes a storefront' do
      delete "/api/v2/storefronts/#{storefront.id}", headers: headers
      expect(response).to have_http_status(:no_content)
    end

    it 'raises an error if the storefront cannot be deleted' do
      delete "/api/v2/storefronts/0", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end