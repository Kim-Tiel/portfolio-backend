class Education < ApplicationRecord
  has_many :education_milestones, -> { order(occurred_on: :asc) }, dependent: :destroy, inverse_of: :education
  accepts_nested_attributes_for :education_milestones, allow_destroy: true,
                                                       reject_if: proc { |attrs|
                                                         attrs['description'].blank? && attrs['occurred_on'].blank?
                                                       }
<<<<<<< HEAD

  validates :institution, :degree, presence: true
=======
  validates :institution, :degree, :field, :start_date, :end_date, :is_graduated, presence: true
>>>>>>> origin/develop

  default_scope { order(sort_order: :asc) }
end
