class LanguageSpoken < ApplicationRecord
  validates :name, :level, :status, presence: true

  default_scope { order(sort_order: :asc) }
end
