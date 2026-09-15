require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Educations', type: :request do
  let!(:admin) { create(:admin, email: 'admin@example.com', password: 'password123') }

  let(:token) do
    post '/api/v1/login', params: { email: 'admin@example.com', password: 'password123' }
    JSON.parse(response.body).fetch('token')
  end

  let(:auth) { { 'Authorization' => "Bearer #{token}" } }

  describe 'GET /api/v1/admin/education' do
    it 'lists education records' do
      create_list(:education, 2)

      get '/api/v1/admin/education', headers: auth

      expect(response).to have_http_status(:ok)
      expect(json_body.size).to eq(2)
    end

    it 'requires authentication' do
      get '/api/v1/admin/education'

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /api/v1/admin/education' do
    it 'requires authentication' do
      post '/api/v1/admin/education',
           params: { education: { institution: 'MIT', degree: 'BS', field: 'CS',
                                  start_date: '2018-01-01', end_date: '2022-01-01', is_graduated: true } }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/v1/admin/education/:id' do
    it 'requires authentication' do
      education = create(:education)

      patch "/api/v1/admin/education/#{education.id}", params: { education: { degree: 'MS' } }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /api/v1/admin/education/:id' do
    it 'requires authentication' do
      education = create(:education)

      delete "/api/v1/admin/education/#{education.id}"

      expect(response).to have_http_status(:unauthorized)
      expect(Education.exists?(education.id)).to be true
    end
  end

  def json_body
    JSON.parse(response.body)
  end
end
