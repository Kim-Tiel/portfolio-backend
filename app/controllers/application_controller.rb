class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def render_not_found
    render json: { error: 'Not found' }, status: :not_found
  end

  # Return the secret used to sign/verify JWTs. Prefer a dedicated credential, fall back to secret_key_base or ENV.
  def jwt_secret
    Rails.application.credentials.dig(:jwt, :secret) ||
      Rails.application.credentials.secret_key_base ||
      ENV['JWT_SECRET'] ||
      Rails.application.secrets.secret_key_base
  end

  # Issue a JWT for the given admin. Default expiry: 30 days from now.
  def issue_token(admin, exp = 30.days.from_now)
    payload = { admin_id: admin.id, exp: exp.to_i }
    JWT.encode(payload, jwt_secret, 'HS256')
  end
end
