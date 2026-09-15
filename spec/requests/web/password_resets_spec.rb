require 'rails_helper'

RSpec.describe 'Web::PasswordResets', type: :request do
  let(:admin) { create(:admin, email: 'admin@example.com') }

  describe 'POST /forgot_password' do
    it 'sends a reset email when the address matches an admin' do
      expect do
        post '/forgot_password', params: { email: admin.email }
      end.to have_enqueued_mail(PasswordMailer, :reset_password)

      expect(response.body).to include("If an account with that email exists")
      expect(admin.reload.password_reset_token_digest).to be_present
    end

    it 'shows the same generic message for an unknown email (no enumeration)' do
      expect do
        post '/forgot_password', params: { email: 'nobody@example.com' }
      end.not_to have_enqueued_mail(PasswordMailer, :reset_password)

      expect(response.body).to include("If an account with that email exists")
    end
  end

  describe 'rate limiting POST /forgot_password' do
    around do |example|
      previous_store = Rack::Attack.cache.store
      previous_enabled = Rack::Attack.enabled
      Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
      Rack::Attack.enabled = true
      example.run
      Rack::Attack.cache.store = previous_store
      Rack::Attack.enabled = previous_enabled
    end

    it 'returns 429 once the per-email limit is hit (the tighter of the two throttles)' do
      3.times do
        post '/forgot_password', params: { email: admin.email }
        expect(response).to have_http_status(:ok)
      end

      post '/forgot_password', params: { email: admin.email }

      expect(response).to have_http_status(:too_many_requests)
    end
  end

  # A signed_id alone only proves the token is well-formed, unexpired, and
  # issued for this purpose — it says nothing about whether it's the token
  # currently on file for this admin, which is what actually makes a link
  # single-use. `issue_current_token` mints one the same way `create` does,
  # so tests below exercise the real invariant instead of a bare signed_id.
  def issue_current_token(admin, expires_in: 30.minutes)
    token = admin.signed_id(purpose: :password_reset, expires_in: expires_in)
    admin.update_column(:password_reset_token_digest, Digest::SHA256.hexdigest(token))
    token
  end

  describe 'GET /forgot_password/edit' do
    it 'accepts a valid, currently-issued token' do
      token = issue_current_token(admin)

      get '/forgot_password/edit', params: { token: token }

      expect(response).to have_http_status(:ok)
    end

    it 'rejects a missing or invalid token' do
      get '/forgot_password/edit', params: { token: 'not-a-real-token' }

      expect(response).to redirect_to(new_password_reset_path)
      follow_redirect!
      expect(response.body).to include('invalid or has expired')
    end

    it 'rejects an expired token' do
      token = issue_current_token(admin, expires_in: -1.minute)

      get '/forgot_password/edit', params: { token: token }

      expect(response).to redirect_to(new_password_reset_path)
    end

    it 'rejects a well-formed token that was never actually issued (no digest on file)' do
      # Same shape as a real token, but the admin's password_reset_token_digest
      # is still nil — this is the case the digest check exists to catch.
      token = admin.signed_id(purpose: :password_reset, expires_in: 30.minutes)

      get '/forgot_password/edit', params: { token: token }

      expect(response).to redirect_to(new_password_reset_path)
    end

    it 'rejects a superseded token once a newer reset has been requested' do
      # signed_id is deterministic (same payload + same expiry -> the same
      # string), so the two expiries must differ or this test can't tell
      # "old" and "new" apart.
      old_token = issue_current_token(admin, expires_in: 30.minutes)
      issue_current_token(admin, expires_in: 29.minutes) # overwrites the stored digest

      get '/forgot_password/edit', params: { token: old_token }

      expect(response).to redirect_to(new_password_reset_path)
    end
  end

  describe 'PATCH /forgot_password/edit' do
    it 'updates the password with a valid, currently-issued token' do
      token = issue_current_token(admin)

      patch '/forgot_password/edit', params: {
        token: token,
        admin: { password: 'newpassword123', password_confirmation: 'newpassword123' }
      }

      expect(response).to have_http_status(:ok)
      expect(admin.reload.authenticate('newpassword123')).to be_truthy
    end

    it 'rejects an invalid token instead of changing the password' do
      patch '/forgot_password/edit', params: {
        token: 'not-a-real-token',
        admin: { password: 'newpassword123', password_confirmation: 'newpassword123' }
      }

      expect(response).to redirect_to(new_password_reset_path)
      expect(admin.reload.authenticate('newpassword123')).to be_falsey
    end

    it 'cannot be used a second time' do
      token = issue_current_token(admin)

      patch '/forgot_password/edit', params: {
        token: token,
        admin: { password: 'newpassword123', password_confirmation: 'newpassword123' }
      }
      expect(response).to have_http_status(:ok)

      patch '/forgot_password/edit', params: {
        token: token,
        admin: { password: 'anotherpassword456', password_confirmation: 'anotherpassword456' }
      }

      expect(response).to redirect_to(new_password_reset_path)
      expect(admin.reload.authenticate('anotherpassword456')).to be_falsey
      expect(admin.authenticate('newpassword123')).to be_truthy
    end
  end
end
