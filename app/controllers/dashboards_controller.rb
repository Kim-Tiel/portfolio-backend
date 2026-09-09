class DashboardsController < Web::BaseController
  layout 'admin'
  before_action :authenticate_admin!

  def index
    @profile = Profile.instance
    @stat_cards = build_stat_cards
    @recent_contact_messages = ContactMessage.limit(5)
    @skills_by_category = skills_by_category
    @contact_messages_by_day = contact_messages_by_day
    @health_checks = build_health_checks
  end

  private

  def build_stat_cards
    [
      { label: 'Projects', value: Project.count, sub: "#{Project.featured.count} featured",
        path: admin_projects_path, icon: :projects },
      { label: 'Skills', value: Skill.count, sub: "#{Skill.distinct.count(:category)} categories",
        path: admin_skills_path, icon: :skills },
      { label: 'Experience', value: Experience.count, sub: 'roles',
        path: admin_resource_path('experiences'), icon: :experiences },
      { label: 'Education', value: Education.count, sub: 'entries',
        path: admin_resource_path('educations'), icon: :educations },
      { label: 'Messages', value: ContactMessage.count, sub: "#{ContactMessage.where(is_read: false).count} unread",
        path: admin_resource_path('contact_messages'), icon: :messages },
      { label: 'Memory Log', value: MemoryLogEntry.count,
        sub: "#{MemoryLogEntry.where(is_approved: false).count} pending",
        path: admin_resource_path('memory_log_entries'), icon: :memory }
    ]
  end

  def build_health_checks
    [
      { label: 'Bio written', done: @profile.bio.present? },
      { label: 'Avatar uploaded', done: @profile.avatar.attached? },
      { label: 'Resume uploaded', done: @profile.resume.attached? },
      { label: 'At least one featured project', done: Project.featured.exists? },
      { label: 'At least one featured skill', done: Skill.featured.exists? }
    ]
  end

  # `.reorder(nil)` clears Skill's default `order(sort_order:, name:)` —
  # Postgres rejects a GROUP BY query whose ORDER BY references a column
  # that isn't grouped or aggregated.
  def skills_by_category
    Skill.reorder(nil).group(:category).count.transform_keys(&:titleize)
  end

  # groupdate fills in every day in the range with 0, even ones with no
  # messages — a bare `.group(...).count` would silently skip them instead.
  # `.reorder(nil)` clears ContactMessage's default `order(created_at: :desc)`
  # for the same reason as the Skill query above.
  def contact_messages_by_day
    ContactMessage.reorder(nil).group_by_day(:created_at, last: 14).count
  end
end
