require 'base64'
require 'tempfile'

# In-memory uploaded files for specs, so tests don't depend on committed
# binary fixtures.
module UploadHelpers
  # Smallest valid PNG: 1x1 transparent pixel.
  PNG_1PX = Base64.decode64(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='
  ).freeze

  def image_upload(filename: 'avatar.png', content_type: 'image/png', bytes: PNG_1PX)
    uploaded_file(filename, content_type, bytes)
  end

  def non_image_upload(filename: 'not_an_image.txt')
    uploaded_file(filename, 'text/plain', 'this is not an image')
  end

  def oversized_image_upload(megabytes: 6)
    image_upload(bytes: '0' * (megabytes * 1.megabyte))
  end

  private

  def uploaded_file(filename, content_type, bytes)
    tempfile = Tempfile.new([File.basename(filename, '.*'), File.extname(filename)])
    tempfile.binmode
    tempfile.write(bytes)
    tempfile.rewind
    Rack::Test::UploadedFile.new(tempfile, content_type, original_filename: filename)
  end
end

RSpec.configure do |config|
  config.include UploadHelpers
end
