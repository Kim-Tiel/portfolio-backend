require 'rails_helper'

RSpec.describe 'Health check', type: :request do
  it 'responds ok at /up with no authentication' do
    get '/up'

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq('status' => 'ok')
  end
end
