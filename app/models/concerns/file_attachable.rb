module FileAttachable
  extend ActiveSupport::Concern

  MAX_SIZE = 10.megabytes
  ALLOWED_CONTENT_TYPES = %w[application/pdf].freeze

  class_methods do
    def has_file(name)
      has_one_attached name

      validate { validate_attached_file(name) }

      define_method("#{name}_url") do
        attached = public_send(name)
        return unless attached.attached?

        Rails.application.routes.url_helpers.rails_blob_url(attached)
      end
    end
  end

  private

  def validate_attached_file(name)
    attached = public_send(name)
    return unless attached.attached?

    blob = attached.blob

    if blob.byte_size > FileAttachable::MAX_SIZE
      errors.add(name, "must be smaller than #{FileAttachable::MAX_SIZE / 1.megabyte}MB")
    end

    return if FileAttachable::ALLOWED_CONTENT_TYPES.include?(blob.content_type)

    errors.add(name, 'must be a PDF')
  end
end
