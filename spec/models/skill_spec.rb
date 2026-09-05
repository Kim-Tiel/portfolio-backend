require 'rails_helper'

RSpec.describe Skill, type: :model do
  describe '.featured' do
    it 'returns only skills flagged as featured' do
      featured = create(:skill, is_featured: true)
      create(:skill, is_featured: false)

      expect(Skill.featured).to contain_exactly(featured)
    end
  end
end
