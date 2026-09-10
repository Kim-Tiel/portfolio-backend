class MemoryLogEntry < ApplicationRecord
  MAX_LINKS = 1
  DEDUP_WINDOW = 24.hours

  # Zero-width / bidi-control / formatting chars (soft hyphen; ZWSP..RLM;
  # bidi embeddings + overrides; word joiner + invisible operators; bidi
  # isolates; BOM). Written as \u escapes so this source is copy-safe.
  INVISIBLE_FORMATTING = /[\u00AD\u200B-\u200F\u202A-\u202E\u2060-\u2064\u2066-\u2069\uFEFF]/
  # C0/C1 control chars, keeping tab (U+0009) and newline (U+000A); plus DEL.
  CONTROL_CHARS = /[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/
  LINE_SEPARATORS = /[\u2028\u2029]|\r\n?/

  before_validation :default_display_name
  before_validation :sanitize_text_fields

  validates :display_name, presence: true, length: { maximum: 60 }
  validates :message, presence: true, length: { maximum: 280 }
  validate :message_link_limit
  validate :not_a_recent_duplicate, on: :create

  default_scope { order(created_at: :desc) }
  scope :approved, -> { where(is_approved: true) }

  # Peppered so a guessed IP can't be confirmed by recomputing a bare
  # SHA-256 (the IPv4 space is small enough to brute-force otherwise).
  def self.hash_ip(ip)
    Digest::SHA256.hexdigest("#{Rails.application.secret_key_base}:memory_log:#{ip}")
  end

  private

  def default_display_name
    self.display_name = 'Anonymous' if display_name.blank?
  end

  def sanitize_text_fields
    self.display_name = scrub(display_name, single_line: true)
    self.message = scrub(message, single_line: false)
  end

  def scrub(value, single_line:)
    return value if value.blank?

    text = value.to_s.unicode_normalize(:nfc)
    text = text.gsub(INVISIBLE_FORMATTING, '').gsub(CONTROL_CHARS, '')
    text = text.gsub(LINE_SEPARATORS, "\n")
    text =
      if single_line
        text.gsub(/\s+/, ' ')
      else
        text.gsub(/[^\S\n]+/, ' ').gsub(/\n{3,}/, "\n\n")
      end
    text.strip
  end

  def message_link_limit
    return if message.blank?

    errors.add(:message, "can't contain links") if message.scan(%r{https?://}i).size > MAX_LINKS
  end

  def not_a_recent_duplicate
    return if message.blank? || ip_hash.blank?

    duplicate = MemoryLogEntry.where(message: message, ip_hash: ip_hash)
                              .where('created_at > ?', DEDUP_WINDOW.ago)
                              .exists?
    errors.add(:base, 'Looks like you already left that note.') if duplicate
  end
end
