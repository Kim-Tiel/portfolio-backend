require 'rails_helper'

RSpec.describe 'Api::V1::MemoryLogEntries', type: :request do
  def json_body
    JSON.parse(response.body)
  end

  describe 'GET /api/v1/memory_log_entries' do
    it 'returns approved entries newest-first with the documented keys' do
      old = create(:memory_log_entry, message: 'first')
      old.update_column(:created_at, 2.days.ago)
      create(:memory_log_entry, message: 'second')
      create(:memory_log_entry, :unapproved, message: 'hidden')

      get '/api/v1/memory_log_entries'

      expect(response).to have_http_status(:ok)
      expect(json_body.map { |e| e['message'] }).to eq(%w[second first])
      expect(json_body.first.keys).to match_array(%w[id display_name message created_at])
      expect(json_body.map { |e| e['id'] }).not_to include(be_nil)
      expect(json_body.pluck('message')).not_to include('hidden')
    end

    it 'caps the response at 50 entries' do
      create_list(:memory_log_entry, 51)
      get '/api/v1/memory_log_entries'
      expect(json_body.size).to eq(50)
    end
  end

  describe 'POST /api/v1/memory_log_entries' do
    it 'creates an entry and returns it' do
      expect do
        post '/api/v1/memory_log_entries',
             params: { memory_log_entry: { display_name: 'Ada', message: 'love it' } }
      end.to change(MemoryLogEntry, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json_body).to include('display_name' => 'Ada', 'message' => 'love it')
      expect(json_body['id']).to be_present
      expect(MemoryLogEntry.last.ip_hash).to be_present
    end

    it 'stores a blank name as "Anonymous"' do
      post '/api/v1/memory_log_entries',
           params: { memory_log_entry: { display_name: '', message: 'hi there' } }

      expect(response).to have_http_status(:created)
      expect(json_body['display_name']).to eq('Anonymous')
    end

    it 'silently accepts and drops a honeypot submission' do
      expect do
        post '/api/v1/memory_log_entries',
             params: { memory_log_entry: { message: 'spam', nickname: 'gotcha' } }
      end.not_to change(MemoryLogEntry, :count)

      expect(response).to have_http_status(:created)
      expect(json_body).to eq('status' => 'ok')
    end

    it 'rejects a blank message with 422' do
      post '/api/v1/memory_log_entries',
           params: { memory_log_entry: { message: '' } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_body['errors']).to be_present
    end

    it 'rejects a duplicate note from the same visitor with 422' do
      2.times do
        post '/api/v1/memory_log_entries',
             params: { memory_log_entry: { message: 'same exact words' } }
      end

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_body['errors'].join).to match(/already left that note/i)
    end

    it 'never returns ip_hash or moderation state' do
      post '/api/v1/memory_log_entries',
           params: { memory_log_entry: { message: 'hello' } }

      expect(json_body.keys).to match_array(%w[id display_name message created_at])
    end

    it 'ignores is_approved and ip_hash sent as params' do
      post '/api/v1/memory_log_entries',
           params: { memory_log_entry: { message: 'sneaky', is_approved: false, ip_hash: 'fake' } }

      entry = MemoryLogEntry.last
      expect(entry.is_approved).to be(true)
      expect(entry.ip_hash).not_to eq('fake')
      expect(entry.ip_hash).to eq(MemoryLogEntry.hash_ip('127.0.0.1'))
    end

    it 'rejects a body larger than 8 KB with 413' do
      post '/api/v1/memory_log_entries',
           params: { memory_log_entry: { message: 'a' * 9_000 } }

      expect(response).to have_http_status(:payload_too_large)
      expect(MemoryLogEntry.count).to eq(0)
    end

    it 'stores a <script> payload verbatim and the admin index escapes it' do
      admin = create(:admin)

      post '/api/v1/memory_log_entries',
           params: { memory_log_entry: { display_name: 'x', message: '<script>alert(1)</script>' } }
      expect(MemoryLogEntry.last.message).to eq('<script>alert(1)</script>')

      sign_in_as(admin)
      get '/admin/memory_log_entries'

      expect(response.body).to include('&lt;script&gt;')
      expect(response.body).not_to include('<script>alert(1)</script>')
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
        post '/api/v1/memory_log_entries',
             params: { memory_log_entry: { message: "note #{i}" } }
        expect(response).to have_http_status(:created)
      end

      post '/api/v1/memory_log_entries',
           params: { memory_log_entry: { message: 'one too many' } }

      expect(response).to have_http_status(:too_many_requests)
      expect(JSON.parse(response.body)).to eq('error' => 'Too many requests, please try again later.')
    end
  end
end
