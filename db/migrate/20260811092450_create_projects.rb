class CreateProjects < ActiveRecord::Migration[6.1]
  def change
    create_table :projects, id: :uuid do |t|
      t.string :slug, null: false
      t.string :title, null: false
      t.string :client_type
      t.string :location
      t.text :summary, null: false
      t.text :description
      t.string :status, null: false, default: 'live'
      t.string :site_url
      t.string :repo_url
      t.string :image_url
      t.boolean :is_featured, null: false, default: false
      t.integer :sort_order, null: false, default: 0
      t.date :started_on
      t.date :completed_on
      t.timestamps
    end
    add_index :projects, :slug, unique: true
    add_index :projects, :is_featured
    add_index :projects, :status
  end
end
