require 'rails_helper'

RSpec.describe 'Categories API', type: :request do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{token}" } }
  let!(:category) { create(:category, name: 'Electronics') }

  describe 'GET /categories' do
    it 'returns all categories' do
      get '/api/v1/categories', headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(Category.count)
    end
  end

  describe 'GET /categories/:id' do
    context 'when the category exists' do
      it 'returns the category' do
        get "/api/v1/categories/#{category.id}", headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['name']).to eq('Electronics')
      end
    end

    context 'when the category does not exist' do
      it 'returns a not found message' do
        get '/api/v1/categories/999', headers: headers
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq("Category not found")
      end
    end
  end

  describe 'POST /categories' do
    let(:valid_attributes) { { name: 'Furniture' } }
    let(:invalid_attributes) { { name: '' } }

    context 'when the request is valid' do
      it 'creates a category' do
        post '/api/v1/categories', params: valid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['name']).to eq('Furniture')
      end
    end

    context 'when the request is invalid' do
      it 'returns a validation error' do
        post '/api/v1/categories', params: invalid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Name can't be blank")
      end
    end
  end

  describe 'PUT /categories/:id' do
    let(:valid_attributes) { { 
      category: {name: 'Home Appliances'}
     } }

    context 'when the category exists' do
      it 'updates the category' do
        put "/api/v1/categories/#{category.id}", params: valid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['name']).to eq('Home Appliances')
      end
    end

    context 'when the category does not exist' do
      it 'returns a not found message' do
        put '/api/v1/categories/999', params: valid_attributes.to_json, headers: headers
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq("Category not found")
      end
    end
  end

  describe 'DELETE /categories/:id' do
    context 'when the category exists' do
      it 'deletes the category' do
        expect {
          delete "/api/v1/categories/#{category.id}", headers: headers
        }.to change(Category, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when the category does not exist' do
      it 'returns a not found message' do
        delete '/api/v1/categories/999', headers: headers
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq("Category not found")
      end
    end
  end
end
