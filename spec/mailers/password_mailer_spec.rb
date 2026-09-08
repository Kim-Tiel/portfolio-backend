require 'rails_helper'

RSpec.describe PasswordMailer, type: :mailer do
  describe '#reset_password' do
    let(:admin) { create(:admin, email: 'admin@example.com') }
    let(:token) { admin.signed_id(purpose: :password_reset, expires_in: 30.minutes) }
    let(:mail) { described_class.reset_password(admin, token) }

    it 'is addressed to the admin, with the expected subject' do
      expect(mail.to).to eq(['admin@example.com'])
      expect(mail.subject).to eq('Reset your Portfolio Admin password')
    end

    it 'includes a reset link carrying the token' do
      # The mail body is quoted-printable encoded and the token is
      # URL-escaped in the link, so compare against the decoded,
      # URL-escaped form rather than the raw token.
      expect(mail.text_part.decoded).to include(CGI.escape(token))
      expect(mail.text_part.decoded).to include('/forgot_password/edit')
    end
  end
end
