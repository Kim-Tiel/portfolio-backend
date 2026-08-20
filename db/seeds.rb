# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

admin_email = ENV.fetch("ADMIN_EMAIL") { Rails.application.credentials.dig(:admin, :email) }
admin_password = ENV.fetch("ADMIN_PASSWORD") { Rails.application.credentials.dig(:admin, :password) }

if admin_email.present? && admin_password.present?
  admin = Admin.find_or_initialize_by(email: admin_email.downcase)
  admin.password = admin_password
  admin.password_confirmation = admin_password
  admin.save!
  puts "Seeded admin account: #{admin.email}"
else
  puts "Skipping admin seed: set ADMIN_EMAIL and ADMIN_PASSWORD (env or credentials) to seed an admin account."
end

# --- Profile -----------------------------------------------------------

profile = Profile.instance
profile.update!(
  name: "Kim Anderson G. Tiel",
  title: "Software Engineer",
  location: "Valenzuela City, Philippines",
  timezone: "Asia/Manila",
  years_career_experience: 10
)
puts "Seeded profile: #{profile.name}"

# --- Skills --------------------------------------------------------------

skills_data = [
  { name: "Ruby on Rails", category: "backend" },
  { name: "Vue.js", category: "frontend" },
  { name: "React.js", category: "frontend" }
]

skills_by_name = {}
skills_data.each_with_index do |attrs, index|
  skill = Skill.find_or_create_by!(name: attrs[:name]) do |s|
    s.category = attrs[:category]
    s.sort_order = index
  end
  skills_by_name[attrs[:name]] = skill
end
puts "Seeded #{skills_by_name.size} skills"

# --- Experiences -----------------------------------------------------------

experiences_data = [
  {
    company: "Information Managers, Inc.",
    role: "Jr. Programmer",
    start_date: Date.new(2016, 7, 1),
    end_date: Date.new(2019, 3, -1),
    highlights: [
      "Engineered reusable, modular code components and resolved complex software defects, reducing development time and ensuring system stability across multiple projects.",
      "Developed automated test scripts using Capybara that simulated real user stories, increasing test coverage and significantly reducing manual testing effort."
    ],
    skills: ["Capybara"]
  }
]

experiences_data.each_with_index do |attrs, index|
  experience = Experience.find_or_create_by!(company: attrs[:company], role: attrs[:role]) do |e|
    e.start_date = attrs[:start_date]
    e.end_date = attrs[:end_date]
    e.sort_order = index
  end
  experience.update!(start_date: attrs[:start_date], end_date: attrs[:end_date], sort_order: index)

  attrs[:highlights].each_with_index do |text, h_index|
    experience.experience_highlights.find_or_create_by!(text: text) do |h|
      h.sort_order = h_index
    end
  end

  attrs[:skills].each do |skill_name|
    skill = skills_by_name[skill_name]
    experience.skills << skill unless experience.skills.include?(skill)
  end
end
puts "Seeded #{experiences_data.size} experiences"

# --- Education ---------------------------------------------------------

education = Education.find_or_create_by!(institution: "STI College of Meycauayan", degree: "Bachelor of Science") do |ed|
  ed.field = "Information Technology"
  ed.start_date = Date.new(2012, 6, 1)
  ed.end_date = Date.new(2016, 3, -1)
  ed.is_graduated = true
  ed.sort_order = 0
end
puts "Seeded education: #{education.institution}"
