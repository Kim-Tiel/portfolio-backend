class ExperienceHighlight < ApplicationRecord
  belongs_to :experience, inverse_of: :experience_highlights
end
