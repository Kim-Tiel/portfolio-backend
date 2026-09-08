class AddContactFieldsAndNamePartsToProfiles < ActiveRecord::Migration[6.1]
  def up
    add_column :profiles, :first_name, :string
    add_column :profiles, :middle_name, :string
    add_column :profiles, :last_name, :string
    add_column :profiles, :linkedin_url, :string
    add_column :profiles, :github_url, :string
    add_column :profiles, :email, :string

    # Best-effort split of the existing free-text `name` into parts, so
    # first_name/last_name aren't blank for whatever profile row already
    # exists. Anything beyond first/last collapses into middle_name.
    execute <<~SQL.squish
      UPDATE profiles
      SET first_name = split_part(trim(name), ' ', 1),
          last_name = CASE
            WHEN array_length(regexp_split_to_array(trim(name), '\\s+'), 1) > 1
            THEN (regexp_split_to_array(trim(name), '\\s+'))[array_length(regexp_split_to_array(trim(name), '\\s+'), 1)]
            ELSE split_part(trim(name), ' ', 1)
          END,
          middle_name = CASE
            WHEN array_length(regexp_split_to_array(trim(name), '\\s+'), 1) > 2
            THEN array_to_string(
              (regexp_split_to_array(trim(name), '\\s+'))[2:array_length(regexp_split_to_array(trim(name), '\\s+'), 1) - 1],
              ' '
            )
            ELSE NULL
          END
      WHERE name IS NOT NULL AND trim(name) <> ''
    SQL

    change_column_null :profiles, :first_name, false
    change_column_null :profiles, :last_name, false
  end

  def down
    remove_column :profiles, :first_name
    remove_column :profiles, :middle_name
    remove_column :profiles, :last_name
    remove_column :profiles, :linkedin_url
    remove_column :profiles, :github_url
    remove_column :profiles, :email
  end
end
