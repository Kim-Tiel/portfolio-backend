class ContactMessage < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :body, presence: true

  default_scope { order(created_at: :desc) }
end
