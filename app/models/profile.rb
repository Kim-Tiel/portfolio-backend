class Profile < ApplicationRecord
  include ImageAttachable

  has_image :avatar

  validates :name, :title, presence: true

  def self.instance
    first_or_create!(name: 'Kim Anderson Tiel', title: 'Full-Stack Developer')
  end
end
