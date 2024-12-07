require 'rails_helper'

RSpec.describe 'Api::V1::Auth', type: :request do
  let(:user) { create(:user) }

  describe 'POST /auth/signup' do
    context 'when valid parameters are provided' do
      it 'creates a new user' do
        post '/api/v1/auth/signup', params: { email: 'test@example.com', password: 'password123', password_confirmation: 'password123' }
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('User created successfully')
      end
    end

    context 'when invalid parameters are provided' do
      it 'returns an error' do
        post '/api/v1/auth/signup', params: { email: '', password: 'password123', password_confirmation: 'password123' }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Email can't be blank")
      end
    end
  end

  describe 'POST /auth/login' do
    context 'when valid credentials are provided' do
      it 'returns a token and user info' do
        post '/api/v1/auth/login', params: { email: user.email, password: 'password123' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include('token', 'user')
      end
    end

    context 'when invalid credentials are provided' do
      it 'returns an error' do
        post '/api/v1/auth/login', params: { email: user.email, password: 'wrongpassword' }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Invalid email or password')
      end
    end
  end

  # describe 'GET /auth/auto_login' do
  #   context 'when a valid token is provided' do
  #     it 'returns the current user' do
  #       token = JsonWebToken.encode(user_id: user.id)
  #       get '/api/v1/auth/auto_login', headers: { Authorization: "Bearer #{token}" }
  #       expect(response).to have_http_status(:ok)
  #       expect(JSON.parse(response.body)['user']['email']).to eq(user.email)
  #     end
  #   end

  #   context 'when an invalid token is provided' do
  #     it 'returns an unauthorized error' do
  #       get '/api/v1/auth/auto_login', headers: { Authorization: 'Bearer invalidtoken' }
  #       expect(response).to have_http_status(:unauthorized)
  #       expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
  #     end
  #   end
  # end
end
