class ProjectMetric < ApplicationRecord
  belongs_to :project

  validates :label, :value, presence: true
end
