module AdminAuthenticatable
  extend ActiveSupport::Concern

  included do
    # controllers including this concern may call before_action :authenticate_admin!
  end

  def authenticate_admin!
    token = request.headers['Authorization']&.split&.last
    payload = JWT.decode(token, jwt_secret, true, algorithm: 'HS256').first
    @current_admin = ::Admin.find(payload['admin_id'])
  rescue JWT::ExpiredSignature
    render json: { error: 'Session expired, please log in again' }, status: :unauthorized
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
