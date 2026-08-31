class PasswordResetsController < Web::BaseController
  before_action :require_reset_admin, only: %i[edit update]

  def new; end

  def create
    admin = ::Admin.find_by(email: params[:email]&.downcase)

    if admin
      session[:password_reset_admin_id] = admin.id
      redirect_to edit_password_reset_path
    else
      flash.now[:alert] = 'No account found with that email.'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @admin = reset_admin
  end

  def update
    @admin = reset_admin

    if params.dig(:admin, :password).blank?
      @admin.errors.add(:password, "can't be blank")
      return render :edit, status: :unprocessable_entity
    end

    if @admin.update(password_params)
      session.delete(:password_reset_admin_id)
      render :success
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def reset_admin
    ::Admin.find(session[:password_reset_admin_id])
  end

  def require_reset_admin
    return if session[:password_reset_admin_id]

    redirect_to new_password_reset_path, alert: 'Please enter your email first.'
  end

  def password_params
    params.require(:admin).permit(:password, :password_confirmation)
  end
end
