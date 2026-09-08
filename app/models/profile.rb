class Profile < ApplicationRecord
  include ImageAttachable
  include FileAttachable

  has_image :avatar
  has_file :resume

  URL_REGEXP = %r{\Ahttps?://}

  before_validation :compute_name

  validates :first_name, :last_name, :title, presence: true
  validates :linkedin_url, format: { with: URL_REGEXP, message: 'must start with http:// or https://' }, allow_blank: true
  validates :github_url, format: { with: URL_REGEXP, message: 'must start with http:// or https://' }, allow_blank: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  def self.instance
    first_or_create!(first_name: 'Kim', middle_name: 'Anderson', last_name: 'Tiel', title: 'Full-Stack Developer')
  end

  private

  # Keeps the denormalized `name` column (still used by the public API
  # response and older views) in sync with the structured name parts,
  # so first/middle/last stay the single source of truth.
  def compute_name
    self.name = [first_name, middle_name, last_name].map(&:presence).compact.join(' ')
  end
end
