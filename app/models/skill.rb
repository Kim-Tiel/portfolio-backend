class Skill < ApplicationRecord
  include ImageAttachable

  # SVG only, and a much smaller cap than photo uploads (Profile
  # avatar/Project image) — this is a small vector logo, not a picture.
  has_image :icon, allowed_types: %w[image/svg+xml], max_size: 1.megabyte, type_label: 'SVG image'

  def icon=(attachable)
    @icon_source_bytes = attachable.read if attachable.respond_to?(:read)
    attachable.rewind if attachable.respond_to?(:rewind)
    super
  end

  validate :icon_has_no_executable_content, if: -> { icon.attached? && icon.blob.content_type == 'image/svg+xml' }

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

  private

  def icon_has_no_executable_content
    return if @icon_source_bytes.nil?

    doc = Nokogiri::XML(@icon_source_bytes) { |config| config.strict.nonet }
    errors.add(:icon, 'must not contain scripts, embedded HTML, or event handlers') if svg_doc_has_executable_content?(doc)
  rescue Nokogiri::XML::SyntaxError
    errors.add(:icon, 'is not a valid SVG file')
  end

  def svg_doc_has_executable_content?(doc)
    doc.xpath('//*[local-name()="script" or local-name()="foreignObject"]').any? ||
      doc.xpath('//@*[starts-with(local-name(), "on")]').any? ||
      doc.xpath('//@*').any? { |attr| attr.value.to_s.strip.downcase.start_with?('javascript:') }
  end
end
