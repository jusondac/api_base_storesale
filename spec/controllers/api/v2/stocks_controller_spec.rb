require 'rails_helper'

RSpec.describe "Stocks API", type: :request do
  let(:user) { create(:user) } # Assuming a user factory exists
  let(:auth_token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { "Authorization" => "Bearer #{auth_token}", "Content-Type" => "application/json" } }

  let(:invoice) { create(:invoice) } # Assuming an invoice factory exists
  let(:valid_payment_params) { { invoice_id: invoice.id, amount: 100.50, payment_method: "credit_card" } }
  let(:invalid_payment_params) { { invoice_id: nil, amount: nil, payment_method: nil } }

  describe 'GET /api/v2/stocks' do
    it 'returns all stocks' do
      get '/api/v2/stocks', headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(Payment.count)
    end

    it 'return not authorize' do
      get '/api/v2/stocks', params: valid_payment_params.to_json
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
    end
  end
end
