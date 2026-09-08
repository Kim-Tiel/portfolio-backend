class ApplicationMailer < ActionMailer::Base
  # Must be a verified identity in AWS SES.
  default from: ENV.fetch('MAILER_FROM_EMAIL', 'from@example.com')
  layout 'mailer'
end
