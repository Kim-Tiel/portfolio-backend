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

  # Minimal but structurally valid single-page PDF.
  MINIMAL_PDF = <<~PDF.freeze
    %PDF-1.1
    1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj
    2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj
    3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 200 200] >> endobj
    xref
    0 4
    0000000000 65535 f
    trailer << /Size 4 /Root 1 0 R >>
    startxref
    0
    %%EOF
  PDF

  def pdf_upload(filename: 'resume.pdf', content_type: 'application/pdf', bytes: MINIMAL_PDF)
    uploaded_file(filename, content_type, bytes)
  end

  def non_pdf_upload(filename: 'not_a_pdf.txt')
    uploaded_file(filename, 'text/plain', 'this is not a pdf')
  end

  def oversized_pdf_upload(megabytes: 11)
    pdf_upload(bytes: MINIMAL_PDF + ('0' * (megabytes * 1.megabyte)))
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
