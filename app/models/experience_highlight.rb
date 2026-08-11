class ExperienceHighlight < ApplicationRecord
  belongs_to :experience

  validates :text, presence: true
end
