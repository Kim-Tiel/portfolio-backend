require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Profiles', type: :request do
  let!(:admin) { create(:admin, email: 'admin@example.com', password: 'password123') }

  let(:token) do
    post '/api/v1/login', params: { email: 'admin@example.com', password: 'password123' }
    JSON.parse(response.body).fetch('token')
  end

  let(:auth) { { 'Authorization' => "Bearer #{token}" } }

  describe 'PATCH /api/v1/admin/profile' do
    it 'updates structured name parts and contact links' do
      patch '/api/v1/admin/profile',
            params: {
              profile: {
                first_name: 'Ada', middle_name: 'Augusta', last_name: 'Lovelace',
                title: 'Engineer', email: 'ada@example.com',
                linkedin_url: 'https://linkedin.com/in/ada', github_url: 'https://github.com/ada'
              }
            },
            headers: auth

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['name']).to eq('Ada Augusta Lovelace')
      expect(body['first_name']).to eq('Ada')
      expect(body['email']).to eq('ada@example.com')
      expect(body['linkedin_url']).to eq('https://linkedin.com/in/ada')
      expect(body['github_url']).to eq('https://github.com/ada')
    end

    it 'requires authentication' do
      patch '/api/v1/admin/profile', params: { profile: { title: 'Engineer' } }

      expect(response).to have_http_status(:unauthorized)
    end
  end

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

  describe 'PUT /api/v1/admin/profile/resume' do
    it 'attaches the uploaded PDF and returns its url' do
      put '/api/v1/admin/profile/resume',
          params: { resume: pdf_upload }, headers: auth

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['resume_url']).to match(%r{/rails/active_storage/blobs/.*resume\.pdf\z})
      expect(Profile.instance.resume).to be_attached
    end

    it 'rejects a non-PDF upload' do
      put '/api/v1/admin/profile/resume',
          params: { resume: non_pdf_upload }, headers: auth

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to be_present
      expect(Profile.instance.resume).not_to be_attached
    end

    it 'requires authentication' do
      put '/api/v1/admin/profile/resume', params: { resume: pdf_upload }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /api/v1/admin/profile/resume' do
    it 'removes the attached resume' do
      Profile.instance.update!(resume: pdf_upload)

      delete '/api/v1/admin/profile/resume', headers: auth

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['resume_url']).to be_nil
      expect(Profile.instance.resume).not_to be_attached
    end
  end
end
