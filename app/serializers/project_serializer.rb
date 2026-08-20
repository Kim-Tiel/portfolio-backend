class ProjectSerializer
  def initialize(project)
    @project = project
  end

  def as_json
    {
      id: @project.id,
      slug: @project.slug,
      title: @project.title,
      client_type: @project.client_type,
      location: @project.location,
      summary: @project.summary,
      description: @project.description,
      status: @project.status,
      site_url: @project.site_url,
      repo_url: @project.repo_url,
      image_url: @project.image_url,
      is_featured: @project.is_featured,
      started_on: @project.started_on,
      completed_on: @project.completed_on,
      skills: @project.skills.map { |s| SkillSerializer.new(s).as_json },
      metrics: @project.project_metrics.map { |m| { label: m.label, value: m.value } }
    }
  end
end
