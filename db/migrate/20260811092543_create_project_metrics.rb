class CreateProjectMetrics < ActiveRecord::Migration[6.1]
  def change
    create_table :project_metrics, id: :uuid do |t|
      t.references :project, null: false, type: :uuid, foreign_key: true
      t.string :label, null: false
      t.string :value, null: false
      t.integer :sort_order, null: false, default: 0
      t.timestamps
    end
  end
end
