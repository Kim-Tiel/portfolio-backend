class ProjectMetric < ApplicationRecord
  belongs_to :project, inverse_of: :project_metrics

  validates :label, :value, presence: true
end
