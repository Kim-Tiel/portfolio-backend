class Education < ApplicationRecord
  has_many :education_milestones, -> { order(occurred_on: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :education_milestones, allow_destroy: true

  validates :institution, :degree, presence: true

  default_scope { order(sort_order: :asc) }
end
