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

  describe 'resume attachment' do
    it 'accepts a PDF' do
      profile.resume = pdf_upload

      expect(profile).to be_valid
      expect(profile.save).to be(true)
    end

    it 'rejects a non-PDF file' do
      profile.resume = non_pdf_upload

      expect(profile).not_to be_valid
      expect(profile.errors[:resume].join).to match(/PDF/i)
    end

    it 'rejects a PDF larger than 10MB' do
      profile.resume = oversized_pdf_upload

      expect(profile).not_to be_valid
      expect(profile.errors[:resume].join).to match(/10MB/)
    end

    it 'exposes resume_url only when a file is attached' do
      expect(profile.resume_url).to be_nil

      profile.update!(resume: pdf_upload)

      expect(profile.resume_url).to start_with('http://www.example.com')
      expect(profile.resume_url).to match(%r{/rails/active_storage/blobs/.*resume\.pdf\z})
    end
  end

  describe 'name parts' do
    it 'computes the full name from first/middle/last' do
      profile.update!(first_name: 'Ada', middle_name: 'Augusta', last_name: 'Lovelace')

      expect(profile.name).to eq('Ada Augusta Lovelace')
    end

    it 'omits a blank middle name from the computed full name' do
      profile.update!(first_name: 'Ada', middle_name: '', last_name: 'Lovelace')

      expect(profile.name).to eq('Ada Lovelace')
    end

    it 'requires first_name and last_name' do
      profile.first_name = ''
      profile.last_name = ''

      expect(profile).not_to be_valid
      expect(profile.errors[:first_name]).to be_present
      expect(profile.errors[:last_name]).to be_present
    end
  end

  describe 'contact links' do
    it 'accepts a valid email' do
      profile.email = 'kim@example.com'
      expect(profile).to be_valid
    end

    it 'rejects an invalid email' do
      profile.email = 'not-an-email'
      expect(profile).not_to be_valid
    end

    it 'requires linkedin_url and github_url to start with http(s)://' do
      profile.linkedin_url = 'linkedin.com/in/kim'
      expect(profile).not_to be_valid
      expect(profile.errors[:linkedin_url]).to be_present

      profile.linkedin_url = 'https://linkedin.com/in/kim'
      profile.github_url = 'not-a-url'
      expect(profile).not_to be_valid
      expect(profile.errors[:github_url]).to be_present
    end
  end
end
