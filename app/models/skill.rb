class Skill < ApplicationRecord
  enum category: {
    language: 'language',
    frontend: 'frontend',
    backend: 'backend',
    infrastructure: 'infrastructure',
    ai: 'ai'
  }

  has_many :project_skills, dependent: :destroy
  has_many :projects, through: :project_skills

  has_many :experience_skills, dependent: :destroy
  has_many :experiences, through: :experience_skills

  validates :name, presence: true, uniqueness: true
  validates :category, presence: true

  default_scope { order(sort_order: :asc, name: :asc) }
  scope :featured, -> { where(is_featured: true) }
end
