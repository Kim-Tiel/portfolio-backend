class CreateExperienceSkills < ActiveRecord::Migration[6.1]
  def change
    create_table :experience_skills, id: :uuid do |t|
      t.references :experience, null: false, type: :uuid, foreign_key: true
      t.references :skill, null: false, type: :uuid, foreign_key: true
      t.timestamps
    end
    add_index :experience_skills, %i[experience_id skill_id], unique: true
  end
end
