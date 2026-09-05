require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Skills', type: :request do
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
end
