require 'rails_helper'

RSpec.describe Project, type: :model do
  let(:project) { build(:project) }

  describe 'image attachment' do
    it 'accepts a PNG image' do
      project.image = image_upload

      expect(project).to be_valid
      expect(project.save).to be(true)
    end

    it 'rejects a non-image file' do
      project.image = non_image_upload

      expect(project).not_to be_valid
      expect(project.errors[:image].join).to match(/PNG|JPEG|image/i)
    end

    it 'rejects an image larger than 5MB' do
      project.image = oversized_image_upload

      expect(project).not_to be_valid
      expect(project.errors[:image].join).to match(/5MB/)
    end

    it 'exposes the attached blob url when an image is attached' do
      project.update!(image: image_upload)

      expect(project.image_url).to start_with('http://www.example.com')
      expect(project.image_url).to match(%r{/rails/active_storage/blobs/.*avatar\.png\z})
    end

    it 'falls back to the placeholder url when no image is attached' do
      expect(project.image_url).to include('project-placeholder')
    end
  end
end
