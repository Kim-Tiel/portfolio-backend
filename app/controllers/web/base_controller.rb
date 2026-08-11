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
            reset_session
            return @current_admin = nil
          end
        end

        # sliding expiration: extend on activity
        session[:admin_expires_at] = 10.hours.from_now.to_i

        @current_admin = ::Admin.find_by(id: session[:admin_id])
      else
        @current_admin = nil
      end
    end

    def admin_signed_in?
      !!current_admin
    end

    def authenticate_admin!
      return if admin_signed_in?

      redirect_to login_path, alert: 'Please sign in to continue'
    end
  end
end
