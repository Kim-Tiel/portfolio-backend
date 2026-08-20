class CreateContactMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :contact_messages, id: :uuid do |t|
      t.string :name
      t.string :email, null: false
      t.string :subject
      t.text :body, null: false
      t.boolean :is_read, null: false, default: false
      t.string :ip_hash
      t.timestamps
    end
    add_index :contact_messages, :created_at
  end
end
