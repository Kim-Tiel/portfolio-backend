FactoryBot.define do
  factory :experience do
    sequence(:company) { |n| "Company #{n}" }
    role { 'Full-Stack Developer' }
    start_date { 1.year.ago.to_date }
  end
end
