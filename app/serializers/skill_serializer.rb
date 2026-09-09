class SkillSerializer
  def initialize(skill)
    @skill = skill
  end

  def as_json
    {
      id: @skill.id,
      name: @skill.name,
      category: @skill.category,
      proficiency: @skill.proficiency,
      proficiency_percent: @skill.proficiency_percent,
      icon_url: @skill.icon_url,
      is_featured: @skill.is_featured
    }
  end
end
