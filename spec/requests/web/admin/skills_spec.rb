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
end
