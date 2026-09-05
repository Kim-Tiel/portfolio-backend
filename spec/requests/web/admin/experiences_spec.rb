require 'rails_helper'

RSpec.describe 'Web::Admin::Experiences', type: :request do
  let(:admin) { create(:admin) }

  describe 'GET /admin/experiences' do
    it 'shows only one page worth of rows and a pagination control' do
      create_list(:experience, 3)
      sign_in_as(admin)

      get '/admin/experiences', params: { per_page: 2 }

      expect(response).to have_http_status(:ok)
      expect(response.body.scan('<tr>').size - 1).to eq(2)
      expect(response.body).to include('pagination')
    end
  end
end
