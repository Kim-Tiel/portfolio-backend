require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Projects', type: :request do
  describe 'GET /api/v1/admin/projects' do
    it 'paginates results and reports pagination meta' do
      create_list(:project, 3)

      get '/api/v1/admin/projects', params: { per_page: 2 }

      expect(response).to have_http_status(:ok)
      expect(json_body['data'].size).to eq(2)
      expect(json_body['meta']).to include(
        'current_page' => 1, 'total_pages' => 2, 'total_count' => 3, 'per_page' => 2
      )
    end

    it 'returns the requested page' do
      create_list(:project, 3)

      get '/api/v1/admin/projects', params: { per_page: 2, page: 2 }

      expect(json_body['data'].size).to eq(1)
      expect(json_body['meta']['current_page']).to eq(2)
    end
  end

  def json_body
    JSON.parse(response.body)
  end
end
