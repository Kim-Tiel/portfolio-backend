# Reusable single-image attachment for any model.
#
#   class Project < ApplicationRecord
#     include ImageAttachable
#     has_image :cover
#   end
#
# Provides, per declared image:
#   * an Active Storage `has_one_attached` association
#   * content-type and size validation (see ALLOWED_CONTENT_TYPES / MAX_SIZE)
#   * a `<name>_url` helper returning the Rails proxy URL, or nil when unattached
module ImageAttachable
  extend ActiveSupport::Concern

  MAX_SIZE = 5.megabytes
  ALLOWED_CONTENT_TYPES = %w[image/png image/jpeg image/webp image/gif].freeze

  class_methods do
    def has_image(name)
      has_one_attached name

      validate { validate_attached_image(name) }

      define_method("#{name}_url") do
        attached = public_send(name)
        return unless attached.attached?

        Rails.application.routes.url_helpers.rails_blob_url(attached)
      end
    end
  end

  private

  def validate_attached_image(name)
    attached = public_send(name)
    return unless attached.attached?

    blob = attached.blob

    if blob.byte_size > ImageAttachable::MAX_SIZE
      errors.add(name, "must be smaller than #{ImageAttachable::MAX_SIZE / 1.megabyte}MB")
    end

    return if ImageAttachable::ALLOWED_CONTENT_TYPES.include?(blob.content_type)

    errors.add(name, 'must be a PNG, JPEG, WebP, or GIF image')
  end
end
