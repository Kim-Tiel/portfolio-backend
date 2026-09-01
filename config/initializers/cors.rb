# Be sure to restart your server when you modify this file.

# Allows the separately-deployed portfolio-web frontend (and local dev) to
# call the public read endpoints and the contact form. Origins come from
# PORTFOLIO_WEB_ORIGINS (comma-separated), e.g.
# "http://localhost:5173,https://portfolio-web.vercel.app".
#
# No auth/cookies cross this boundary — the public API is unauthenticated
# reads plus one unauthenticated write (contact form) — so credentials
# stay disabled. The JWT-protected /api/v1/admin/* namespace is not
# covered by this and does not need CORS opened up.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch('PORTFOLIO_WEB_ORIGINS', '').split(',')

    resource '/api/v1/*',
             headers: :any,
             methods: %i[get post options],
             credentials: false
  end
end
