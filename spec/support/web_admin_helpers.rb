# Signs an admin into the web (session-based) admin panel from a request spec.
module WebAdminHelpers
  def sign_in_as(admin, password: 'password123')
    post '/login', params: { email: admin.email, password: password }
  end
end

RSpec.configure do |config|
  config.include WebAdminHelpers, type: :request
end
