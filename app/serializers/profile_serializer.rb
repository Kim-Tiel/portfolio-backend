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
      years_shipping: @profile.years_shipping,
      completed_projects: @profile.completed_projects,
      countries_worked_in: @profile.countries_worked_in,
      employer_satisfaction: @profile.employer_satisfaction,
      available_for: @profile.available_for,
      avatar_url: @profile.avatar_url,
      hero_tagline: @profile.hero_tagline
    }
  end
end
