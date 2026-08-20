class EducationMilestone < ApplicationRecord
  belongs_to :education

  validates :occurred_on, :description, presence: true
end
