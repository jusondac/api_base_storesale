require 'rails_helper'

RSpec.describe "Payments API", type: :request do
  let(:user) { create(:user) } # Assuming a user factory exists
  let(:auth_token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { "Authorization" => "Bearer #{auth_token}", "Content-Type" => "application/json" } }

  let(:invoice) { create(:invoice) } # Assuming an invoice factory exists
  let(:valid_payment_params) { { invoice_id: invoice.id, amount: 100.50, status: "completed", payment_method: "credit_card" } }
  let(:invalid_payment_params) { { invoice_id: nil, amount: nil, payment_method: nil } }

  describe 'GET /payments' do
    it 'returns all payments' do
      get '/api/v2/payments', headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(Payment.count)
    end

    it 'return not authorize' do
      get '/api/v2/payments', params: valid_payment_params.to_json
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
    end
  end

  describe "POST /api/v2/payments" do
    context "with valid parameters" do
      it "creates a payment and updates the invoice status" do
        post '/api/v2/payments', params: valid_payment_params.to_json, headers: headers

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include("message" => "Payment successful")
      end
    end

    context "with invalid parameters" do
      it "returns a 422 status and error message" do
        post '/api/v2/payments', params: invalid_payment_params.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include("error")
      end
    end

    context "without authentication" do
      it "returns a 401 unauthorized status" do
        post '/api/v2/payments', params: valid_payment_params.to_json

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
      end
    end
  end
end
