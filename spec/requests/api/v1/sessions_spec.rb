require 'rails_helper'

RSpec.describe "Api::V1::Sessions", type: :request do
  describe "POST /api/v1/login" do
    let!(:admin) { create(:admin, email: "admin@example.com", password: "password123") }

    it "returns a JWT for valid credentials" do
      post "/api/v1/login", params: { email: "admin@example.com", password: "password123" }

      expect(response).to have_http_status(:ok)
      expect(json_body["token"]).to be_present
    end

    it "rejects invalid credentials" do
      post "/api/v1/login", params: { email: "admin@example.com", password: "wrong" }

      expect(response).to have_http_status(:unauthorized)
      expect(json_body["error"]).to be_present
    end

    it "rejects an unknown email" do
      post "/api/v1/login", params: { email: "nobody@example.com", password: "password123" }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  def json_body
    JSON.parse(response.body)
  end
end
