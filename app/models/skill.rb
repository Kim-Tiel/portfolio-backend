class Skill < ApplicationRecord
  include ImageAttachable

  # SVG only, and a much smaller cap than photo uploads (Profile
  # avatar/Project image) — this is a small vector logo, not a picture.
  has_image :icon, allowed_types: %w[image/svg+xml], max_size: 1.megabyte, type_label: 'SVG image'

  enum category: {
    language: 'language',
    frontend: 'frontend',
    backend: 'backend',
    infrastructure: 'infrastructure',
    ai: 'ai'
  }

  # Collapsed from a looser 5-term scale (see the
  # NormalizeSkillProficiencyValues migration) — "proficient" and
  # "advanced" always rendered identically on the frontend anyway, so
  # there was no real distinction lost.
  enum proficiency: {
    beginner: 'beginner',
    intermediate: 'intermediate',
    advanced: 'advanced',
    expert: 'expert'
  }

  has_many :project_skills, dependent: :destroy
  has_many :projects, through: :project_skills

  has_many :experience_skills, dependent: :destroy
  has_many :experiences, through: :experience_skills

  validates :name, presence: true, uniqueness: true
  validates :category, presence: true
  validates :proficiency, presence: true
  validates :proficiency_percent,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  default_scope { order(sort_order: :asc, name: :asc) }
  scope :featured, -> { where(is_featured: true) }
end
