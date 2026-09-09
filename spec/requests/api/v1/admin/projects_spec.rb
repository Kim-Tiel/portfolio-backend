require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Projects', type: :request do
  let!(:admin) { create(:admin, email: 'admin@example.com', password: 'password123') }

  let(:token) do
    post '/api/v1/login', params: { email: 'admin@example.com', password: 'password123' }
    JSON.parse(response.body).fetch('token')
  end

  let(:auth) { { 'Authorization' => "Bearer #{token}" } }

  describe 'GET /api/v1/admin/projects' do
    it 'paginates results and reports pagination meta' do
      create_list(:project, 3)

      get '/api/v1/admin/projects', params: { per_page: 2 }, headers: auth

      expect(response).to have_http_status(:ok)
      expect(json_body['data'].size).to eq(2)
      expect(json_body['meta']).to include(
        'current_page' => 1, 'total_pages' => 2, 'total_count' => 3, 'per_page' => 2
      )
    end

    it 'returns the requested page' do
      create_list(:project, 3)

      get '/api/v1/admin/projects', params: { per_page: 2, page: 2 }, headers: auth

      expect(json_body['data'].size).to eq(1)
      expect(json_body['meta']['current_page']).to eq(2)
    end

    it 'requires authentication' do
      get '/api/v1/admin/projects'

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PUT /api/v1/admin/projects/:id/image' do
    it 'attaches the uploaded image and returns its url' do
      project = create(:project)

      put "/api/v1/admin/projects/#{project.id}/image", params: { image: image_upload }, headers: auth

      expect(response).to have_http_status(:ok)
      expect(json_body['image_url']).to match(%r{/rails/active_storage/blobs/.*avatar\.png\z})
      expect(project.reload.image).to be_attached
    end

    it 'rejects a non-image upload' do
      project = create(:project)

      put "/api/v1/admin/projects/#{project.id}/image", params: { image: non_image_upload }, headers: auth

      expect(response).to have_http_status(:unprocessable_entity)
      expect(project.reload.image).not_to be_attached
    end

    it 'requires authentication' do
      project = create(:project)

      put "/api/v1/admin/projects/#{project.id}/image", params: { image: image_upload }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /api/v1/admin/projects/:id/image' do
    it 'removes the attached image, falling back to the placeholder url' do
      project = create(:project, image: image_upload)

      delete "/api/v1/admin/projects/#{project.id}/image", headers: auth

      expect(response).to have_http_status(:ok)
      expect(json_body['image_url']).to include('project-placeholder')
      expect(project.reload.image).not_to be_attached
    end
  end

  def json_body
    JSON.parse(response.body)
  end
end
