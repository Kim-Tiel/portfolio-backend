FactoryBot.define do
  factory :education do
    sequence(:institution) { |n| "University #{n}" }
    degree { 'BS' }
    field { 'Computer Science' }
    start_date { 4.years.ago.to_date }
    end_date { 1.year.ago.to_date }
    is_graduated { true }
  end
end
