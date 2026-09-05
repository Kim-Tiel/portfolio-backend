FactoryBot.define do
  factory :project do
    sequence(:slug) { |n| "project-#{n}" }
    sequence(:title) { |n| "Project #{n}" }
    summary { 'A portfolio project.' }
  end
end
