FactoryBot.define do
  factory :contact_message do
    sequence(:name) { |n| "Visitor #{n}" }
    sequence(:email) { |n| "visitor#{n}@example.com" }
    subject { 'Project inquiry' }
    body { 'I would like to discuss a project with you.' }
  end
end
