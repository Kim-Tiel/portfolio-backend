class Project < ApplicationRecord
  enum status: { live: 'live', in_progress: 'in_progress', archived: 'archived' }

  has_many :project_skills, dependent: :destroy
  has_many :skills, through: :project_skills

  has_many :project_metrics, -> { order(sort_order: :asc) }, dependent: :destroy, inverse_of: :project
  accepts_nested_attributes_for :project_metrics, allow_destroy: true,
                                                  reject_if: proc { |attrs|
                                                    attrs['label'].blank? && attrs['value'].blank?
                                                  }

  validates :slug, presence: true, uniqueness: true,
                   format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: 'must be lowercase, hyphen-separated' }
  validates :title, :summary, presence: true

  default_scope { order(sort_order: :asc) }
  scope :featured, -> { where(is_featured: true) }
end
