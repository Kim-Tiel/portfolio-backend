class ProfileSerializer
  def initialize(profile)
    @profile = profile
  end

  def as_json
    {
      name: @profile.name,
      first_name: @profile.first_name,
      middle_name: @profile.middle_name,
      last_name: @profile.last_name,
      title: @profile.title,
      location: @profile.location,
      timezone: @profile.timezone,
      years_career_experience: @profile.years_career_experience,
      completed_projects: @profile.completed_projects,
      employer_satisfaction: @profile.employer_satisfaction,
      available_for: @profile.available_for,
      avatar_url: @profile.avatar_url,
      hero_tagline: @profile.hero_tagline,
      bio: @profile.bio,
      email: @profile.email,
      linkedin_url: @profile.linkedin_url,
      github_url: @profile.github_url,
      resume_url: @profile.resume_url
    }
  end
end
