class AddBioToProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :bio, :text
  end
end
