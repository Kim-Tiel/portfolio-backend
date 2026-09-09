require 'rails_helper'

RSpec.describe Skill, type: :model do
  let(:skill) { build(:skill) }

  describe '.featured' do
    it 'returns only skills flagged as featured' do
      featured = create(:skill, is_featured: true)
      create(:skill, is_featured: false)

      expect(Skill.featured).to contain_exactly(featured)
    end
  end

  describe 'proficiency_percent' do
    it 'defaults to 80 for a new record' do
      expect(create(:skill).proficiency_percent).to eq(80)
    end

    it 'accepts any integer from 0 to 100' do
      skill.proficiency_percent = 45

      expect(skill).to be_valid
    end

    it 'rejects a value above 100' do
      skill.proficiency_percent = 101

      expect(skill).not_to be_valid
      expect(skill.errors[:proficiency_percent]).to be_present
    end

    it 'rejects a negative value' do
      skill.proficiency_percent = -1

      expect(skill).not_to be_valid
      expect(skill.errors[:proficiency_percent]).to be_present
    end
  end

  describe 'icon attachment' do
    it 'accepts an SVG image' do
      skill.icon = svg_upload

      expect(skill).to be_valid
      expect(skill.save).to be(true)
    end

    it 'rejects a non-SVG image' do
      skill.icon = image_upload

      expect(skill).not_to be_valid
      expect(skill.errors[:icon].join).to match(/SVG/i)
    end

    it 'rejects an SVG larger than 1MB' do
      skill.icon = oversized_svg_upload

      expect(skill).not_to be_valid
      expect(skill.errors[:icon].join).to match(/1MB/)
    end

    it 'exposes the attached blob url when an icon is attached' do
      skill.update!(icon: svg_upload)

      expect(skill.icon_url).to start_with('http://www.example.com')
      expect(skill.icon_url).to match(%r{/rails/active_storage/blobs/.*icon\.svg\z})
    end

    it 'returns nil when no icon is attached' do
      expect(skill.icon_url).to be_nil
    end
  end
end
