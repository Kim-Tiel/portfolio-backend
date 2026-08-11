class CreateExperienceHighlights < ActiveRecord::Migration[6.1]
  def change
    create_table :experience_highlights, id: :uuid do |t|
      t.references :experience, null: false, type: :uuid, foreign_key: true
      t.text :text, null: false
      t.integer :sort_order, null: false, default: 0
      t.timestamps
    end
  end
end
