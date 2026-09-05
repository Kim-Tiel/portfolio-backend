class RemoveAvatarUrlFromProfiles < ActiveRecord::Migration[6.1]
  def change
    remove_column :profiles, :avatar_url, :string, if_exists: true
  end
end
