require 'rails_helper'

RSpec.describe Profile, type: :model do
  let(:profile) { Profile.instance }

  def upload(name, content_type)
    Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files', name), content_type)
  end

  describe 'avatar attachment' do
    it 'accepts a PNG image' do
      profile.avatar = upload('avatar.png', 'image/png')

      expect(profile).to be_valid
      expect(profile.save).to be(true)
    end

    it 'rejects a non-image file' do
      profile.avatar = upload('not_an_image.txt', 'text/plain')

      expect(profile).not_to be_valid
      expect(profile.errors[:avatar].join).to match(/PNG|JPEG|image/i)
    end

    it 'rejects an image larger than 5MB' do
      big = Tempfile.new(['big', '.png'])
      big.binmode
      big.write('0' * 6.megabytes)
      big.rewind
      profile.avatar = Rack::Test::UploadedFile.new(big.path, 'image/png')

      expect(profile).not_to be_valid
      expect(profile.errors[:avatar].join).to match(/5MB/)
    ensure
      big&.close!
    end

    it 'exposes avatar_url only when an image is attached' do
      expect(profile.avatar_url).to be_nil

      profile.update!(avatar: upload('avatar.png', 'image/png'))

      expect(profile.avatar_url).to start_with('http://www.example.com')
      expect(profile.avatar_url).to match(%r{/rails/active_storage/blobs/.*avatar\.png\z})
    end
  end
end
