class MemoryLogEntry < ApplicationRecord
  validates :message, presence: true, length: { maximum: 280 }
  validates :display_name, presence: true

  default_scope { order(created_at: :desc) }
  scope :approved, -> { where(is_approved: true) }
end
