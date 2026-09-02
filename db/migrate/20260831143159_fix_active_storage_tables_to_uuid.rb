# The initial Active Storage tables were created with the generator default
# (bigint ids / record_id), but every model in this app uses uuid primary keys,
# so `record_id` could never reference a real record. Recreate the three tables
# with uuid ids. Safe to run on a fresh database too — it simply drops the
# just-created tables and rebuilds them identically to the uuid definition.
class FixActiveStorageTablesToUuid < ActiveRecord::Migration[6.1]
  def up
    return if uuid_column?(:active_storage_attachments, :record_id)

    drop_table :active_storage_variant_records, if_exists: true
    drop_table :active_storage_attachments, if_exists: true
    drop_table :active_storage_blobs, if_exists: true

    create_uuid_tables
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def create_uuid_tables
    create_table :active_storage_blobs, id: :uuid do |t|
      t.string   :key,          null: false
      t.string   :filename,     null: false
      t.string   :content_type
      t.text     :metadata
      t.string   :service_name, null: false
      t.bigint   :byte_size,    null: false
      t.string   :checksum,     null: false
      t.datetime :created_at,   null: false

      t.index [:key], unique: true
    end

    create_table :active_storage_attachments, id: :uuid do |t|
      t.string     :name,   null: false
      t.references :record, null: false, polymorphic: true, index: false, type: :uuid
      t.references :blob,   null: false, type: :uuid

      t.datetime :created_at, null: false

      t.index %i[record_type record_id name blob_id],
              name: 'index_active_storage_attachments_uniqueness', unique: true
      t.foreign_key :active_storage_blobs, column: :blob_id
    end

    create_table :active_storage_variant_records, id: :uuid do |t|
      t.belongs_to :blob, null: false, index: false, type: :uuid
      t.string :variation_digest, null: false

      t.index %i[blob_id variation_digest],
              name: 'index_active_storage_variant_records_uniqueness', unique: true
      t.foreign_key :active_storage_blobs, column: :blob_id
    end
  end

  def uuid_column?(table, column)
    return false unless table_exists?(table)

    columns(table).find { |c| c.name == column.to_s }&.sql_type == 'uuid'
  end
end
