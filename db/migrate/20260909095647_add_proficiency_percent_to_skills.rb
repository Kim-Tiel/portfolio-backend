class AddProficiencyPercentToSkills < ActiveRecord::Migration[6.1]
  def change
    # Defaults to 80 — the same flat value the frontend was hardcoding for
    # every skill before this column existed — so existing rows keep
    # rendering exactly as they do today until an admin sets a real value.
    add_column :skills, :proficiency_percent, :integer, default: 80, null: false
  end
end
