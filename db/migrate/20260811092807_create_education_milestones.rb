class CreateEducationMilestones < ActiveRecord::Migration[6.1]
  def change
    create_table :education_milestones, id: :uuid do |t|
      t.references :education, null: false, type: :uuid, foreign_key: true
      t.date :occurred_on, null: false
      t.text :description, null: false
      t.integer :sort_order, null: false, default: 0
      t.timestamps
    end
  end
end
