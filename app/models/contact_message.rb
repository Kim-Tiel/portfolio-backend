class ContactMessage < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :body, presence: true

  default_scope { order(created_at: :desc) }

  def self.hash_ip(ip)
    Digest::SHA256.hexdigest("#{Rails.application.secret_key_base}:contact_message:#{ip}")
  end
end
