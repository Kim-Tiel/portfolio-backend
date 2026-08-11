class CreateLanguagesSpoken < ActiveRecord::Migration[6.1]
  def change
    create_table :languages_spoken, id: :uuid do |t|
      t.string :name, null: false
      t.string :level, null: false
      t.string :status, null: false
      t.integer :sort_order, null: false, default: 0
      t.timestamps
    end
  end
end
