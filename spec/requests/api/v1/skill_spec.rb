require 'rails_helper'

RSpec.describe 'Api::V1::Skills', type: :request do
  describe 'GET /api/v1/skills' do
    it 'includes the is_featured flag for each skill' do
      create(:skill, is_featured: true)

      get '/api/v1/skills'

      expect(response).to have_http_status(:ok)
      expect(json_body.first).to include('is_featured' => true)
    end

    it 'returns only featured skills when featured=true' do
      featured = create(:skill, name: 'Rails', is_featured: true)
      create(:skill, name: 'jQuery', is_featured: false)

      get '/api/v1/skills', params: { featured: 'true' }

      expect(json_body.map { |s| s['name'] }).to eq([featured.name])
    end

    it 'returns every skill without the filter' do
      create(:skill, is_featured: true)
      create(:skill, is_featured: false)

      get '/api/v1/skills'

      expect(json_body.size).to eq(2)
    end
  end

  def json_body
    JSON.parse(response.body)
  end
end
