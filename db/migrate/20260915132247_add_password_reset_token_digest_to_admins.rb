class AddPasswordResetTokenDigestToAdmins < ActiveRecord::Migration[6.1]
  def change
    add_column :admins, :password_reset_token_digest, :string
  end
end
