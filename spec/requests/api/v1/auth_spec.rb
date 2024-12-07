require 'rails_helper'

RSpec.describe 'Authentication API', type: :request do
  let!(:user) { create_user }

  describe 'POST /api/v1/auth/login' do
    it 'authenticates the user and returns a token' do
      post '/api/v1/auth/login', params: { email: user.email, password: 'password123' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include('token')
    end

    it 'returns unauthorized for invalid credentials' do
      post '/api/v1/auth/login', params: { email: user.email, password: 'wrongpassword' }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('Invalid email or password')
    end
  end

  describe 'POST /api/v1/auth/signup' do
    it 'creates a new user' do
      post '/api/v1/auth/signup', params: { email: 'newuser@example.com', password: 'password123', password_confirmation: 'password123' }
      expect(response).to have_http_status(:created)
      expect(User.last.email).to eq('newuser@example.com')
    end

    it 'returns errors for invalid input' do
      post '/api/v1/auth/signup', params: { email: '', password: 'short', password_confirmation: 'short' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).not_to be_empty
    end
  end
end
