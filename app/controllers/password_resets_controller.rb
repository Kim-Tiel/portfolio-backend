class PasswordResetsController < Web::BaseController
  RESET_TOKEN_EXPIRY = 30.minutes

  # Shown after `create` regardless of whether the email matched an account,
  # so a visitor can't use this form to check which emails have an account.
  GENERIC_SENT_MESSAGE = "If an account with that email exists, we've sent a password reset link to it.".freeze

  def new; end

  def create
    admin = ::Admin.find_by(email: params[:email]&.downcase)

    if admin
      token = admin.signed_id(purpose: :password_reset, expires_in: RESET_TOKEN_EXPIRY)
      PasswordMailer.reset_password(admin, token).deliver_later
    end

    flash.now[:notice] = GENERIC_SENT_MESSAGE
    render :new
  end

  def edit
    @admin = admin_from_token(params[:token])
    return redirect_to_expired unless @admin

    @token = params[:token]
  end

  def update
    @admin = admin_from_token(params[:token])
    return redirect_to_expired unless @admin

    @token = params[:token]

    if params.dig(:admin, :password).blank?
      @admin.errors.add(:password, "can't be blank")
      return render :edit, status: :unprocessable_entity
    end

    if @admin.update(password_params)
      render :success
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # Verifies the token is well-formed, unexpired, and issued for this
  # purpose — returns nil (instead of raising) for anything invalid.
  def admin_from_token(token)
    return nil if token.blank?

    ::Admin.find_signed(token, purpose: :password_reset)
  end

  def redirect_to_expired
    redirect_to new_password_reset_path, alert: 'That reset link is invalid or has expired.'
  end

  def password_params
    params.require(:admin).permit(:password, :password_confirmation)
  end
end
