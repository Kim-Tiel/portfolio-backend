require 'rails_helper'

RSpec.describe 'Web::Dashboard', type: :request do
  let(:admin) { create(:admin) }

  describe 'GET /dashboard' do
    it 'requires authentication' do
      get '/dashboard'

      expect(response).to redirect_to('/login')
    end

    it 'renders stat cards, recent messages, charts, and the health checklist' do
      create(:project, is_featured: true)
      create(:skill, category: 'frontend')
      create(:contact_message, name: 'Ada Lovelace', subject: 'Let\'s work together')
      sign_in_as(admin)

      get '/dashboard'

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Welcome to the CMS')
      expect(response.body).to include('1 featured')
      expect(response.body).to include('Ada Lovelace')
      expect(response.body).to include('Content health')
      expect(response.body).to include('chartkick')
    end

    it 'still renders when there are no contact messages or skills yet' do
      sign_in_as(admin)

      get '/dashboard'

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('No contact messages yet.')
      expect(response.body).to include('No skills yet.')
    end
  end
end
