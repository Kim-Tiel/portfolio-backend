class CreateEducations < ActiveRecord::Migration[6.1]
  def change
    create_table :educations, id: :uuid do |t|
      t.string :institution, null: false
      t.string :degree, null: false
      t.string :field
      t.string :location
      t.date :start_date
      t.date :end_date
      t.boolean :is_graduated, null: false, default: true
      t.integer :sort_order, null: false, default: 0
      t.timestamps
    end
  end
end
