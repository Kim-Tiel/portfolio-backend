class Admin < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  before_save { email.downcase! }
end
