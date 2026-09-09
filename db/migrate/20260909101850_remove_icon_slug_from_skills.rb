class RemoveIconSlugFromSkills < ActiveRecord::Migration[6.1]
  def change
    # Superseded by the real `icon` file attachment (see ImageAttachable) —
    # this was never actually populated or rendered anywhere.
    remove_column :skills, :icon_slug, :string
  end
end
