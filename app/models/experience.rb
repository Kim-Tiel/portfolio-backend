class Experience < ApplicationRecord
  has_many :experience_highlights, -> { order(sort_order: :asc) }, dependent: :destroy
  # Rejects rows with no highlight text, not :all_blank — the sort_order box
  # is auto-filled for every blank padding row, so :all_blank would never
  # see them as empty and they'd fail the ExperienceHighlight text presence
  # validation on save.
  accepts_nested_attributes_for :experience_highlights, allow_destroy: true, reject_if: proc { |attrs| attrs['text'].blank? }

  has_many :experience_skills, dependent: :destroy
  has_many :skills, through: :experience_skills

  validates :company, :role, :start_date, presence: true
  validate :end_date_after_start_date

  default_scope { order(start_date: :desc) }

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    errors.add(:end_date, 'must be after start date') if end_date < start_date
  end
end
