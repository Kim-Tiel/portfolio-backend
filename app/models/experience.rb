class Experience < ApplicationRecord
  has_many :experience_highlights, -> { order(sort_order: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :experience_highlights, allow_destroy: true

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
