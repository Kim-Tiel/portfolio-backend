class AddIsFeaturedToSkills < ActiveRecord::Migration[6.1]
  def change
    add_column :skills, :is_featured, :boolean, null: false, default: false
    add_index :skills, :is_featured
  end
end
