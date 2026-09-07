require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Skills', type: :request do
  describe 'GET /api/v1/admin/skills' do
    it 'paginates results and reports pagination meta' do
      create_list(:skill, 3)

      get '/api/v1/admin/skills', params: { per_page: 2 }

      expect(response).to have_http_status(:ok)
      expect(json_body['data'].size).to eq(2)
      expect(json_body['meta']).to include('total_count' => 3, 'per_page' => 2)
    end
  end

  describe 'POST /api/v1/admin/skills' do
    it 'persists the is_featured flag' do
      post '/api/v1/admin/skills',
           params: { skill: { name: 'Kubernetes', category: 'infrastructure', is_featured: true } }

      expect(response).to have_http_status(:created)
      expect(Skill.find_by(name: 'Kubernetes')).to be_is_featured
    end
  end

  describe 'PATCH /api/v1/admin/skills/:id' do
    it 'updates the is_featured flag' do
      skill = create(:skill, is_featured: false)

      patch "/api/v1/admin/skills/#{skill.id}", params: { skill: { is_featured: true } }

      expect(response).to have_http_status(:ok)
      expect(skill.reload).to be_is_featured
    end
  end

  def json_body
    JSON.parse(response.body)
  end
end
