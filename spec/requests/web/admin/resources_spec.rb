require 'rails_helper'

RSpec.describe 'Web::Admin::Resources', type: :request do
  let(:admin) { create(:admin) }

  before { sign_in_as(admin) }

  describe 'GET /admin/:resource/:id' do
    it 'never renders password_digest, even for the Admin model' do
      get "/admin/admins/#{admin.id}"

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('password_digest')
      expect(response.body).not_to include(admin.password_digest)
    end

    it 'still shows real attributes for a non-sensitive model' do
      skill = create(:skill)

      get "/admin/skills/#{skill.id}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('name')
      expect(response.body).to include(skill.name)
    end

    it 'redirects for a model not on the allowlist' do
      get '/admin/something_else/1'

      expect(response).to redirect_to(dashboard_path)
    end

    it 'requires authentication' do
      delete logout_path

      get "/admin/admins/#{admin.id}"

      expect(response).to redirect_to(login_path)
    end
  end
end
