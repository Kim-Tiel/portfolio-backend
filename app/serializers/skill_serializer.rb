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
      icon_slug: @skill.icon_slug
    }
  end
end
