require 'rails_helper'

RSpec.describe ContactMessage, type: :model do
  it 'is valid with a well-formed factory' do
    expect(build(:contact_message)).to be_valid
  end

  it 'requires an email' do
    expect(build(:contact_message, email: nil)).not_to be_valid
  end

  it 'requires a body' do
    expect(build(:contact_message, body: nil)).not_to be_valid
  end

  describe '.hash_ip' do
    it 'is deterministic and 64 hex chars' do
      hashed = described_class.hash_ip('203.0.113.5')
      expect(hashed).to match(/\A[0-9a-f]{64}\z/)
      expect(described_class.hash_ip('203.0.113.5')).to eq(hashed)
    end

    it 'is peppered (differs from a bare SHA-256 of the IP)' do
      expect(described_class.hash_ip('203.0.113.5'))
        .not_to eq(Digest::SHA256.hexdigest('203.0.113.5'))
    end

    it 'differs from MemoryLogEntry.hash_ip for the same IP' do
      expect(described_class.hash_ip('203.0.113.5'))
        .not_to eq(MemoryLogEntry.hash_ip('203.0.113.5'))
    end
  end
end
