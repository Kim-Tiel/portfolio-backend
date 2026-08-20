class SessionsController < Web::BaseController
  # Render login form
  def new
    # if already signed in and session not expired, send to dashboard
    return redirect_to dashboard_path if admin_signed_in?

    render :new
  end

  # Handle POST /login — authenticate and set session
  def create
    admin = ::Admin.find_by(email: params[:email]&.downcase)
    if admin&.authenticate(params[:password])
      session[:admin_id] = admin.id
      # set session expiry (epoch seconds) using configured TTL
      session[:admin_expires_at] = admin_session_ttl_hours.hours.from_now.to_i
      admin.update(last_login_at: Time.current)
      redirect_to dashboard_path, notice: 'Signed in successfully'
    else
      flash.now[:alert] = 'Invalid email or password'
      render :new, status: :unauthorized
    end
  end

  # Logout
  def destroy
    reset_session
    redirect_to login_path, notice: 'Signed out'
  end
end
