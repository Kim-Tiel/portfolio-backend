class ProfileSerializer
  def initialize(profile)
    @profile = profile
  end

  def as_json
    {
      name: @profile.name,
      title: @profile.title,
      location: @profile.location,
      timezone: @profile.timezone,
      years_career_experience: @profile.years_career_experience,
      completed_projects: @profile.completed_projects,
      employer_satisfaction: @profile.employer_satisfaction,
      available_for: @profile.available_for,
      avatar_url: @profile.avatar_url,
      hero_tagline: @profile.hero_tagline
    }
  end
end
