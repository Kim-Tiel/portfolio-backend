require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Skills', type: :request do
  let!(:admin) { create(:admin, email: 'admin@example.com', password: 'password123') }

  let(:token) do
    post '/api/v1/login', params: { email: 'admin@example.com', password: 'password123' }
    JSON.parse(response.body).fetch('token')
  end

  let(:auth) { { 'Authorization' => "Bearer #{token}" } }

  describe 'GET /api/v1/admin/skills' do
    it 'paginates results and reports pagination meta' do
      create_list(:skill, 3)

      get '/api/v1/admin/skills', params: { per_page: 2 }, headers: auth

      expect(response).to have_http_status(:ok)
      expect(json_body['data'].size).to eq(2)
      expect(json_body['meta']).to include('total_count' => 3, 'per_page' => 2)
    end

    it 'requires authentication' do
      get '/api/v1/admin/skills'

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /api/v1/admin/skills' do
    it 'persists the is_featured flag' do
      post '/api/v1/admin/skills',
           params: { skill: { name: 'Kubernetes', category: 'infrastructure', is_featured: true } },
           headers: auth

      expect(response).to have_http_status(:created)
      expect(Skill.find_by(name: 'Kubernetes')).to be_is_featured
    end
  end

  describe 'PATCH /api/v1/admin/skills/:id' do
    it 'updates the is_featured flag' do
      skill = create(:skill, is_featured: false)

      patch "/api/v1/admin/skills/#{skill.id}", params: { skill: { is_featured: true } }, headers: auth

      expect(response).to have_http_status(:ok)
      expect(skill.reload).to be_is_featured
    end

    it 'updates the proficiency_percent' do
      skill = create(:skill)

      patch "/api/v1/admin/skills/#{skill.id}", params: { skill: { proficiency_percent: 45 } }, headers: auth

      expect(response).to have_http_status(:ok)
      expect(skill.reload.proficiency_percent).to eq(45)
    end

    it 'rejects a proficiency_percent above 100' do
      skill = create(:skill)

      patch "/api/v1/admin/skills/#{skill.id}", params: { skill: { proficiency_percent: 150 } }, headers: auth

      expect(response).to have_http_status(:unprocessable_entity)
      expect(skill.reload.proficiency_percent).not_to eq(150)
    end
  end

  describe 'PUT /api/v1/admin/skills/:id/icon' do
    it 'attaches the uploaded SVG and returns its url' do
      skill = create(:skill)

      put "/api/v1/admin/skills/#{skill.id}/icon", params: { icon: svg_upload }, headers: auth

      expect(response).to have_http_status(:ok)
      expect(json_body['icon_url']).to match(%r{/rails/active_storage/blobs/.*icon\.svg\z})
      expect(skill.reload.icon).to be_attached
    end

    it 'rejects a non-SVG upload' do
      skill = create(:skill)

      put "/api/v1/admin/skills/#{skill.id}/icon", params: { icon: image_upload }, headers: auth

      expect(response).to have_http_status(:unprocessable_entity)
      expect(skill.reload.icon).not_to be_attached
    end

    it 'requires authentication' do
      skill = create(:skill)

      put "/api/v1/admin/skills/#{skill.id}/icon", params: { icon: svg_upload }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /api/v1/admin/skills/:id/icon' do
    it 'removes the attached icon' do
      skill = create(:skill, icon: svg_upload)

      delete "/api/v1/admin/skills/#{skill.id}/icon", headers: auth

      expect(response).to have_http_status(:ok)
      expect(json_body['icon_url']).to be_nil
      expect(skill.reload.icon).not_to be_attached
    end
  end

  def json_body
    JSON.parse(response.body)
  end
end
