require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Profiles avatar', type: :request do
  let!(:admin) { create(:admin, email: 'admin@example.com', password: 'password123') }

  let(:token) do
    post '/api/v1/login', params: { email: 'admin@example.com', password: 'password123' }
    JSON.parse(response.body).fetch('token')
  end

  let(:auth) { { 'Authorization' => "Bearer #{token}" } }

  describe 'PUT /api/v1/admin/profile/avatar' do
    it 'attaches the uploaded image and returns its url' do
      put '/api/v1/admin/profile/avatar',
          params: { avatar: image_upload }, headers: auth

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['avatar_url']).to match(%r{/rails/active_storage/blobs/.*avatar\.png\z})
      expect(Profile.instance.avatar).to be_attached
    end

    it 'rejects a non-image upload' do
      put '/api/v1/admin/profile/avatar',
          params: { avatar: non_image_upload }, headers: auth

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to be_present
      expect(Profile.instance.avatar).not_to be_attached
    end

    it 'requires authentication' do
      put '/api/v1/admin/profile/avatar', params: { avatar: image_upload }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /api/v1/admin/profile/avatar' do
    it 'removes the attached image' do
      Profile.instance.update!(avatar: image_upload)

      delete '/api/v1/admin/profile/avatar', headers: auth

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['avatar_url']).to be_nil
      expect(Profile.instance.avatar).not_to be_attached
    end
  end
end
