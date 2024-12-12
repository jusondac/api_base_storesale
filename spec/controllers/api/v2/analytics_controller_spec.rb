require 'rails_helper'

RSpec.describe "Analytics API", type: :request do
  let(:user) { create(:user) }
  let(:storefront) { create(:storefront, user: user) }
  let(:customer) { create(:customer) }
  let(:order_item) { create(:order_item) }
  let(:product1) { create(:product, storefront: storefront) }
  let(:product2) { create(:product, storefront: storefront) }
  let(:order1) do
    create(:order, customer: customer, total_price: 100.0, status: 'completed', created_at: 1.day.ago)
  end
  let(:order2) do
    create(:order, customer: customer, total_price: 200.0, status: 'completed', created_at: 3.days.ago)
  end

  before do
    # Create order items for analytics
    create(:order_item, order: order1, product: product1, quantity: 5, unit_price: 10.0)
    create(:order_item, order: order2, product: product2, quantity: 10, unit_price: 20.0)
  end
  

  describe 'GET /api/v2/analytics' do
    let(:headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: user.id)}" } }

    context 'when authenticated' do
      it 'returns total revenue' do
        get '/api/v2/analytics', headers: headers
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['total_revenue']).to eq('300.0')
      end

      it 'returns best-selling products' do
        get '/api/v2/analytics', headers: headers
        json_response = JSON.parse(response.body)
        best_selling = json_response['best_selling_products']
        expect(best_selling).to include(a_hash_including('name' => product2.name, 'total_quantity' => 10))
      end

      it 'returns customer lifetime value' do
        get '/api/v2/analytics', headers: headers
        json_response = JSON.parse(response.body)
        clv = json_response['customer_lifetime_value'].first
        expect(clv['name']).to eq(customer.name)
        expect(clv['lifetime_value']).to eq(300.0)
      end

      it 'returns sales by day' do
        get '/api/v2/analytics', headers: headers
        json_response = JSON.parse(response.body)
        expect(json_response['sales_by_day']).to include(a_hash_including('total_price' => "100.0"))
      end

      it 'returns storefront performance' do
        get '/api/v2/analytics', headers: headers
        json_response = JSON.parse(response.body)
        performance = json_response['storefront_performance'].first
        expect(performance['name']).to eq(storefront.name)
        expect(performance['total_revenue']).to eq(300.0)
      end
    end

    context 'when unauthenticated' do
      it 'returns unauthorized error' do
        get '/api/v2/analytics'
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
      end
    end
  end
end
