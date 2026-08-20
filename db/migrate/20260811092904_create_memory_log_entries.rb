class CreateMemoryLogEntries < ActiveRecord::Migration[6.1]
  def change
    create_table :memory_log_entries, id: :uuid do |t|
      t.string :display_name, null: false, default: 'Anonymous'
      t.string :message, null: false, limit: 280
      t.boolean :is_approved, null: false, default: true
      t.string :ip_hash
      t.timestamps
    end
    add_index :memory_log_entries, :created_at
    add_index :memory_log_entries, :is_approved
  end
end
