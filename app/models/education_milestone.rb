class EducationMilestone < ApplicationRecord
  belongs_to :education, inverse_of: :education_milestones

  validates :occurred_on, :description, presence: true
end
