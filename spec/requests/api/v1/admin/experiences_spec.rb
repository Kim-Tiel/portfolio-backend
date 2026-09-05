require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Experiences', type: :request do
  describe 'GET /api/v1/admin/experiences' do
    it 'paginates results and reports pagination meta' do
      create_list(:experience, 3)

      get '/api/v1/admin/experiences', params: { per_page: 2 }

      expect(response).to have_http_status(:ok)
      expect(json_body['data'].size).to eq(2)
      expect(json_body['meta']).to include('total_count' => 3, 'per_page' => 2)
    end
  end

  def json_body
    JSON.parse(response.body)
  end
end
