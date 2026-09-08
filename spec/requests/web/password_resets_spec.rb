require 'rails_helper'

RSpec.describe 'Web::PasswordResets', type: :request do
  let(:admin) { create(:admin, email: 'admin@example.com') }

  describe 'POST /forgot_password' do
    it 'sends a reset email when the address matches an admin' do
      expect do
        post '/forgot_password', params: { email: admin.email }
      end.to have_enqueued_mail(PasswordMailer, :reset_password)

      expect(response.body).to include("If an account with that email exists")
    end

    it 'shows the same generic message for an unknown email (no enumeration)' do
      expect do
        post '/forgot_password', params: { email: 'nobody@example.com' }
      end.not_to have_enqueued_mail(PasswordMailer, :reset_password)

      expect(response.body).to include("If an account with that email exists")
    end
  end

  describe 'GET /forgot_password/edit' do
    it 'accepts a valid token' do
      token = admin.signed_id(purpose: :password_reset, expires_in: 30.minutes)

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
      token = admin.signed_id(purpose: :password_reset, expires_in: -1.minute)

      get '/forgot_password/edit', params: { token: token }

      expect(response).to redirect_to(new_password_reset_path)
    end
  end

  describe 'PATCH /forgot_password/edit' do
    it 'updates the password with a valid token' do
      token = admin.signed_id(purpose: :password_reset, expires_in: 30.minutes)

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
  end
end
