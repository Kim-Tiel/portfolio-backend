# Host used to build absolute URLs (Active Storage image links) from places
# without a request context — models, serializers, jobs.
#
# Development resets `Rails.application.routes.default_url_options` to {} on
# every code reload, so it is re-applied through `to_prepare` (which runs after
# each reload) rather than set once at boot in an environment file.
url_options =
  case Rails.env
  when 'production'
    { host: ENV.fetch('APP_HOST', 'localhost'), protocol: 'https' }
  when 'test'
    { host: 'www.example.com' }
  else
    { host: 'localhost', port: 3000 }
  end

Rails.application.config.to_prepare do
  Rails.application.routes.default_url_options = url_options
end
