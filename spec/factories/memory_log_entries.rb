FactoryBot.define do
  factory :memory_log_entry do
    sequence(:display_name) { |n| "Visitor #{n}" }
    sequence(:message) { |n| "Note number #{n} — thanks for building this." }
    is_approved { true }
    ip_hash { SecureRandom.hex(32) }

    trait :unapproved do
      is_approved { false }
    end
  end
end
