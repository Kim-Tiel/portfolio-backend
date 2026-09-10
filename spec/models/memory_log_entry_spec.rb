require 'rails_helper'

RSpec.describe MemoryLogEntry, type: :model do
  it 'has a valid factory' do
    expect(build(:memory_log_entry)).to be_valid
  end

  describe 'message' do
    it 'is required' do
      entry = build(:memory_log_entry, message: nil)
      expect(entry).not_to be_valid
      expect(entry.errors[:message]).to be_present
    end

    it 'rejects more than 280 characters' do
      entry = build(:memory_log_entry, message: 'a' * 281)
      expect(entry).not_to be_valid
      expect(entry.errors[:message]).to be_present
    end
  end

  describe 'display_name' do
    it 'coerces a blank name to "Anonymous"' do
      entry = create(:memory_log_entry, display_name: '   ')
      expect(entry.display_name).to eq('Anonymous')
    end

    it 'coerces a missing name to "Anonymous"' do
      entry = create(:memory_log_entry, display_name: nil)
      expect(entry.display_name).to eq('Anonymous')
    end

    it 'rejects a name longer than 60 characters' do
      entry = build(:memory_log_entry, display_name: 'x' * 61)
      expect(entry).not_to be_valid
      expect(entry.errors[:display_name]).to be_present
    end
  end

  describe 'link limit' do
    it 'allows a message with one link' do
      entry = build(:memory_log_entry, message: 'nice work, see https://example.com')
      expect(entry).to be_valid
    end

    it 'rejects a message with two or more links' do
      entry = build(:memory_log_entry, message: 'https://a.example https://b.example buy now')
      expect(entry).not_to be_valid
      expect(entry.errors[:message]).to include("can't contain links")
    end
  end

  describe 'duplicate suppression' do
    let(:ip) { SecureRandom.hex(32) }

    it 'rejects the same message from the same ip_hash within 24h' do
      create(:memory_log_entry, message: 'great site', ip_hash: ip)
      dup = build(:memory_log_entry, message: 'great site', ip_hash: ip)
      expect(dup).not_to be_valid
      expect(dup.errors[:base]).to include('Looks like you already left that note.')
    end

    it 'allows the same message from a different ip_hash' do
      create(:memory_log_entry, message: 'great site', ip_hash: ip)
      other = build(:memory_log_entry, message: 'great site', ip_hash: SecureRandom.hex(32))
      expect(other).to be_valid
    end

    it 'allows the same message + ip_hash after 24h' do
      old = create(:memory_log_entry, message: 'great site', ip_hash: ip)
      old.update_column(:created_at, 25.hours.ago)
      again = build(:memory_log_entry, message: 'great site', ip_hash: ip)
      expect(again).to be_valid
    end
  end

  describe '.approved' do
    it 'returns only approved entries' do
      approved = create(:memory_log_entry)
      create(:memory_log_entry, :unapproved)
      expect(MemoryLogEntry.approved).to contain_exactly(approved)
    end
  end

  describe 'sanitization' do
    it 'rejects a message that is only invisible characters' do
      entry = build(:memory_log_entry, message: "\u200B\u200B\uFEFF")
      expect(entry).not_to be_valid
      expect(entry.errors[:message]).to be_present
    end

    it 'strips bidi-override and zero-width characters from the message' do
      entry = create(:memory_log_entry, message: "he\u200Bllo \u202Eworld")
      expect(entry.message).to eq('hello world')
    end

    it 'normalizes CRLF and collapses 3+ blank lines in the message' do
      entry = create(:memory_log_entry, message: "a\r\n\n\n\n\nb")
      expect(entry.message).to eq("a\n\nb")
    end

    it 'forces display_name onto a single line' do
      entry = create(:memory_log_entry, display_name: "Ada\nLovelace")
      expect(entry.display_name).to eq('Ada Lovelace')
    end

    it 'catches a duplicate padded with zero-width characters' do
      ip = SecureRandom.hex(32)
      create(:memory_log_entry, message: 'hello there', ip_hash: ip)
      dup = build(:memory_log_entry, message: "hel\u200Blo there", ip_hash: ip)
      expect(dup).not_to be_valid
      expect(dup.errors[:base]).to include('Looks like you already left that note.')
    end
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
  end
end
