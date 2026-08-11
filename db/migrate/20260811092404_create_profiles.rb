class CreateProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :profiles, id: :uuid do |t|
      t.string :name, null: false
      t.string :title, null: false
      t.string :location
      t.string :timezone
      t.integer :years_shipping
      t.integer :completed_projects
      t.integer :countries_worked_in
      t.decimal :employer_satisfaction, precision: 5, scale: 2
      t.text :available_for, array: true, default: []
      t.string :avatar_url
      t.text :hero_tagline
      t.timestamps
    end
  end
end
