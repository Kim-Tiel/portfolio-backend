require 'rails_helper'

RSpec.describe Profile, type: :model do
  let(:profile) { Profile.instance }

  describe 'avatar attachment' do
    it 'accepts a PNG image' do
      profile.avatar = image_upload

      expect(profile).to be_valid
      expect(profile.save).to be(true)
    end

    it 'rejects a non-image file' do
      profile.avatar = non_image_upload

      expect(profile).not_to be_valid
      expect(profile.errors[:avatar].join).to match(/PNG|JPEG|image/i)
    end

    it 'rejects an image larger than 5MB' do
      profile.avatar = oversized_image_upload

      expect(profile).not_to be_valid
      expect(profile.errors[:avatar].join).to match(/5MB/)
    end

    it 'exposes avatar_url only when an image is attached' do
      expect(profile.avatar_url).to be_nil

      profile.update!(avatar: image_upload)

      expect(profile.avatar_url).to start_with('http://www.example.com')
      expect(profile.avatar_url).to match(%r{/rails/active_storage/blobs/.*avatar\.png\z})
    end
  end
end
