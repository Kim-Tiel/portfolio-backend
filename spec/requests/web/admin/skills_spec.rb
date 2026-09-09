require 'rails_helper'

RSpec.describe 'Web::Admin::Skills', type: :request do
  let(:admin) { create(:admin) }

  describe 'GET /admin/skills' do
    it 'shows only one page worth of rows and a pagination control' do
      create_list(:skill, 3)
      sign_in_as(admin)

      get '/admin/skills', params: { per_page: 2 }

      expect(response).to have_http_status(:ok)
      expect(response.body.scan('<tr>').size - 1).to eq(2)
      expect(response.body).to include('pagination')
    end
  end

  describe 'GET /admin/skills/new' do
    it 'renders the form with a proficiency range slider' do
      sign_in_as(admin)

      get '/admin/skills/new'

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('type="range"')
    end
  end

  describe 'GET /admin/skills/:id/edit' do
    it 'renders the form with the current proficiency_percent as the slider value' do
      skill = create(:skill, proficiency_percent: 65)
      sign_in_as(admin)

      get "/admin/skills/#{skill.id}/edit"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('value="65"')
    end
  end
end
