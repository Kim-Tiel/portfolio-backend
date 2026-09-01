require 'rails_helper'

RSpec.describe 'CORS on Api::V1', type: :request do
  it 'allows the configured frontend origin to read the public API' do
    get '/api/v1/skills', headers: { 'Origin' => ENV.fetch('APP_HOST', '').split(',').first }

    expect(response.headers['Access-Control-Allow-Origin']).to eq(ENV.fetch('APP_HOST', '').split(',').first)
  end

  it 'does not allow an unlisted origin' do
    get '/api/v1/skills', headers: { 'Origin' => 'http://evil.example' }

    expect(response.headers['Access-Control-Allow-Origin']).to be_nil
  end
end
