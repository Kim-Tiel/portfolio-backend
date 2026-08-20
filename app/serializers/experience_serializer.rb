class ExperienceSerializer
  def initialize(experience)
    @experience = experience
  end

  def as_json
    {
      id: @experience.id,
      company: @experience.company,
      role: @experience.role,
      location: @experience.location,
      is_remote: @experience.is_remote,
      start_date: @experience.start_date,
      end_date: @experience.end_date,
      commit_hash: @experience.commit_hash,
      highlights: @experience.experience_highlights.map(&:text),
      skills: @experience.skills.map { |s| SkillSerializer.new(s).as_json }
    }
  end
end
