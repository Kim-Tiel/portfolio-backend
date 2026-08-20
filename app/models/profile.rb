class Profile < ApplicationRecord
  validates :name, :title, presence: true

  def self.instance
    first_or_create!(name: 'Kim Anderson Tiel', title: 'Full-Stack Developer')
  end
end
