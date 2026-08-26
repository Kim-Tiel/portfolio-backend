class Education < ApplicationRecord
  has_many :education_milestones, -> { order(occurred_on: :asc) }, dependent: :destroy, inverse_of: :education
  accepts_nested_attributes_for :education_milestones, allow_destroy: true,
                                                       reject_if: proc { |attrs|
                                                         attrs['description'].blank? && attrs['occurred_on'].blank?
                                                       }
  validates :institution, :degree, :field, :start_date, :end_date, :is_graduated, presence: true

  default_scope { order(sort_order: :asc) }
end
