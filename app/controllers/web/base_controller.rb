module Web
  class BaseController < ActionController::Base
    protect_from_forgery with: :exception

    helper_method :current_admin, :admin_signed_in?

    private

    def current_admin
      return @current_admin if defined?(@current_admin)

      if session[:admin_id]
        # check expiration (stored as epoch seconds)
        if session[:admin_expires_at].present?
          expires_at = Time.at(session[:admin_expires_at].to_i)
          if Time.current > expires_at
            # mark that expiration occurred so authenticate_admin! can surface a friendly message
            @session_expired = true
            reset_session
            return @current_admin = nil
          end
        end

        # sliding expiration: extend on activity
        session[:admin_expires_at] = admin_session_ttl_hours.hours.from_now.to_i

        @current_admin = ::Admin.find_by(id: session[:admin_id])
      else
        @current_admin = nil
      end
    end

    # Number of hours a web admin session should live (integer)
    # Priority: credentials -> ENV -> default 10
    def admin_session_ttl_hours
      cred = Rails.application.credentials.respond_to?(:dig) ? Rails.application.credentials.dig(:admin_session_ttl_hours) : nil
      env = ENV['ADMIN_SESSION_TTL_HOURS']
      (cred || env || 10).to_i
    end

    def session_expired?
      !!@session_expired
    end

    def admin_signed_in?
      !!current_admin
    end

    def authenticate_admin!
      return if admin_signed_in?

      if session_expired?
        redirect_to login_path, alert: 'Your session expired. Please sign in again.'
      else
        redirect_to login_path, alert: 'Please sign in to continue'
      end
    end
  end
end
