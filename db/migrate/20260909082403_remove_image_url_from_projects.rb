class RemoveImageUrlFromProjects < ActiveRecord::Migration[6.1]
  def change
    remove_column :projects, :image_url, :string
  end
end
