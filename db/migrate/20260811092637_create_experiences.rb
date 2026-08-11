class CreateExperiences < ActiveRecord::Migration[6.1]
  def change
    create_table :experiences, id: :uuid do |t|
      t.string :company, null: false
      t.string :role, null: false
      t.string :location
      t.boolean :is_remote, null: false, default: false
      t.date :start_date, null: false
      t.date :end_date
      t.string :commit_hash
      t.integer :sort_order, null: false, default: 0
      t.timestamps
    end
    add_index :experiences, :start_date
  end
end
