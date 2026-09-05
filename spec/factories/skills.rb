FactoryBot.define do
  factory :skill do
    sequence(:name) { |n| "Skill #{n}" }
    category { 'backend' }
    proficiency { 'proficient' }
    is_featured { false }
  end
end
