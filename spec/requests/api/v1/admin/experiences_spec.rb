require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Experiences', type: :request do
  let!(:admin) { create(:admin, email: 'admin@example.com', password: 'password123') }

  let(:token) do
    post '/api/v1/login', params: { email: 'admin@example.com', password: 'password123' }
    JSON.parse(response.body).fetch('token')
  end

  let(:auth) { { 'Authorization' => "Bearer #{token}" } }

  describe 'GET /api/v1/admin/experiences' do
    it 'paginates results and reports pagination meta' do
      create_list(:experience, 3)

      get '/api/v1/admin/experiences', params: { per_page: 2 }, headers: auth

      expect(response).to have_http_status(:ok)
      expect(json_body['data'].size).to eq(2)
      expect(json_body['meta']).to include('total_count' => 3, 'per_page' => 2)
    end

    it 'requires authentication' do
      get '/api/v1/admin/experiences'

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /api/v1/admin/experiences' do
    it 'requires authentication' do
      post '/api/v1/admin/experiences', params: { experience: { company: 'Acme', role: 'Engineer' } }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/v1/admin/experiences/:id' do
    it 'requires authentication' do
      experience = create(:experience)

      patch "/api/v1/admin/experiences/#{experience.id}", params: { experience: { role: 'Staff Engineer' } }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /api/v1/admin/experiences/:id' do
    it 'requires authentication' do
      experience = create(:experience)

      delete "/api/v1/admin/experiences/#{experience.id}"

      expect(response).to have_http_status(:unauthorized)
      expect(Experience.exists?(experience.id)).to be true
    end
  end

  def json_body
    JSON.parse(response.body)
  end
end
