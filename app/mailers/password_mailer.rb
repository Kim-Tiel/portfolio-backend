class PasswordMailer < ApplicationMailer
  # `token` is a Rails signed_id — see Admin#signed_id usage in
  # PasswordResetsController. It expires on its own, no DB column needed.
  def reset_password(admin, token)
    @admin = admin
    @reset_url = edit_password_reset_url(token: token)

    mail(to: @admin.email, subject: 'Reset your Portfolio Admin password')
  end
end
