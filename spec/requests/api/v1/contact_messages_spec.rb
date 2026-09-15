require 'rails_helper'

RSpec.describe 'Api::V1::ContactMessages', type: :request do
  def json_body
    JSON.parse(response.body)
  end

  describe 'POST /api/v1/contact_messages' do
    it 'creates a message and returns sent' do
      expect do
        post '/api/v1/contact_messages',
             params: { contact_message: { name: 'Ada', email: 'ada@example.com', body: 'Hello there' } }
      end.to change(ContactMessage, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json_body).to eq('status' => 'sent')
    end

    it 'rejects a blank body with 422' do
      post '/api/v1/contact_messages',
           params: { contact_message: { email: 'ada@example.com', body: '' } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_body['errors']).to be_present
    end

    it 'stores a peppered ip_hash, not a bare hash of the IP' do
      post '/api/v1/contact_messages',
           params: { contact_message: { email: 'ada@example.com', body: 'Hello there' } }

      message = ContactMessage.last
      expect(message.ip_hash).to eq(ContactMessage.hash_ip('127.0.0.1'))
      expect(message.ip_hash).not_to eq(Digest::SHA256.hexdigest('127.0.0.1'))
    end
  end

  describe 'rate limiting POST' do
    around do |example|
      previous_store = Rack::Attack.cache.store
      previous_enabled = Rack::Attack.enabled
      Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
      Rack::Attack.enabled = true
      example.run
      Rack::Attack.cache.store = previous_store
      Rack::Attack.enabled = previous_enabled
    end

    it 'returns 429 after 3 posts in the burst window from one IP' do
      3.times do |i|
        post '/api/v1/contact_messages',
             params: { contact_message: { email: 'ada@example.com', body: "message #{i}" } }
        expect(response).to have_http_status(:created)
      end

      post '/api/v1/contact_messages',
           params: { contact_message: { email: 'ada@example.com', body: 'one too many' } }

      expect(response).to have_http_status(:too_many_requests)
      expect(json_body).to eq('error' => 'Too many requests, please try again later.')
    end
  end
end
