module ImageAttachable
  extend ActiveSupport::Concern

  DEFAULT_MAX_SIZE = 5.megabytes
  DEFAULT_ALLOWED_CONTENT_TYPES = %w[image/png image/jpeg image/webp image/gif].freeze
  DEFAULT_TYPE_LABEL = 'PNG, JPEG, WebP, or GIF image'.freeze

  class_methods do
    # `allowed_types`/`max_size`/`type_label` let a specific attachment
    # (e.g. a Skill's vector icon) narrow or loosen the defaults below —
    # each `has_image` call captures its own settings, so different
    # attachments on the same class (or different classes entirely) can
    # each enforce their own rules.
    def has_image(name, allowed_types: ImageAttachable::DEFAULT_ALLOWED_CONTENT_TYPES,
                  max_size: ImageAttachable::DEFAULT_MAX_SIZE, type_label: ImageAttachable::DEFAULT_TYPE_LABEL)
      has_one_attached name

      validate do
        attached = public_send(name)
        next unless attached.attached?

        blob = attached.blob

        errors.add(name, "must be smaller than #{max_size / 1.megabyte}MB") if blob.byte_size > max_size

        errors.add(name, "must be a #{type_label}") unless allowed_types.include?(blob.content_type)
      end

      define_method("#{name}_url") do
        attached = public_send(name)
        return unless attached.attached?

        Rails.application.routes.url_helpers.rails_blob_url(attached)
      end
    end
  end
end
