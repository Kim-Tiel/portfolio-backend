class CreateProjectSkills < ActiveRecord::Migration[6.1]
  def change
    create_table :project_skills, id: :uuid do |t|
      t.references :project, null: false, type: :uuid, foreign_key: true
      t.references :skill, null: false, type: :uuid, foreign_key: true
      t.timestamps
    end
    add_index :project_skills, %i[project_id skill_id], unique: true
  end
end
