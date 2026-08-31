class Admin < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true
  before_save { email.downcase! }
end
