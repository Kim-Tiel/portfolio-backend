Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch('PORTFOLIO_WEB_ORIGINS', '').split(',')

    resource '/api/v1/*',
             headers: :any,
             methods: %i[get post options],
             credentials: false
  end
end
