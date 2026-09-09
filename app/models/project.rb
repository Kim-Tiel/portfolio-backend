class Project < ApplicationRecord
  include ImageAttachable

  has_image :image

  enum status: { live: 'live', in_progress: 'in_progress', archived: 'archived' }

  has_many :project_skills, dependent: :destroy
  has_many :skills, through: :project_skills

  has_many :project_metrics, -> { order(sort_order: :asc) }, dependent: :destroy, inverse_of: :project
  accepts_nested_attributes_for :project_metrics, allow_destroy: true,
                                                  reject_if: proc { |attrs|
                                                    attrs['label'].blank? && attrs['value'].blank?
                                                  }

  validates :slug, presence: true, uniqueness: true,
                   format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: 'must be lowercase, hyphen-separated' }
  validates :title, :summary, presence: true

  default_scope { order(sort_order: :asc) }
  scope :featured, -> { where(is_featured: true) }

  # Falls back to a generic placeholder graphic (app/assets/images) so
  # consumers of this URL — the admin form preview, the public API — never
  # have to special-case "no image" themselves.
  #
  # `has_image` defines `image_url` directly on this class (not on an
  # ancestor), so there's no real `super` to call here — re-checking
  # `image.attached?` and building the blob URL ourselves is the
  # straightforward way to layer the fallback on top of it.
  def image_url
    return Rails.application.routes.url_helpers.rails_blob_url(image) if image.attached?

    # The plain Sprockets `image_url` helper only returns an absolute URL
    # when `config.asset_host` is set (it isn't, here) — building it from
    # the same host/protocol already configured for mailer links keeps this
    # consistent with every other URL this API hands back.
    options = Rails.application.config.action_mailer.default_url_options
    host = options[:port] ? "#{options[:host]}:#{options[:port]}" : options[:host]
    protocol = options[:protocol] || 'http'
    "#{protocol}://#{host}#{ActionController::Base.helpers.image_path('project-placeholder.svg')}"
  end
end
