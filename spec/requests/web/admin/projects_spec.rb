require 'rails_helper'

RSpec.describe 'Web::Admin::Projects', type: :request do
  let(:admin) { create(:admin) }

  describe 'GET /admin/projects' do
    it 'shows only one page worth of rows and a pagination control' do
      create_list(:project, 3)
      sign_in_as(admin)

      get '/admin/projects', params: { per_page: 2 }

      expect(response).to have_http_status(:ok)
      expect(response.body.scan('<tr>').size - 1).to eq(2) # minus the header row
      expect(response.body).to include('pagination')
    end

    it 'keeps First/Prev visible (disabled) on the first page instead of hiding them' do
      create_list(:project, 3)
      sign_in_as(admin)

      get '/admin/projects', params: { per_page: 2 }

      expect(response.body).to include('First')
      expect(response.body).to include('Prev')
    end
  end
end
