class CreateAdmins < ActiveRecord::Migration[6.1]
  def change
    create_table :admins, id: :uuid do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.datetime :last_login_at
      t.timestamps
    end
    add_index :admins, :email, unique: true
  end
end
