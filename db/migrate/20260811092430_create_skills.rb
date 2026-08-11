class CreateSkills < ActiveRecord::Migration[6.1]
  def change
    create_table :skills, id: :uuid do |t|
      t.string :name, null: false
      t.string :category, null: false
      t.string :proficiency, null: false, default: 'proficient'
      t.string :icon_slug
      t.integer :sort_order, null: false, default: 0
      t.timestamps
    end
    add_index :skills, :name, unique: true
    add_index :skills, :category
  end
end
