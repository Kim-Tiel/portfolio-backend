class NormalizeSkillProficiencyValues < ActiveRecord::Migration[6.1]
  # `proficiency` becomes a real enum (beginner/intermediate/advanced/expert)
  # in the Skill model right after this — collapsing the old 5-term scale
  # down to those 4. "proficient" was always rendered identically to
  # "advanced" on the frontend (same bar color), so existing rows move
  # there to preserve how they already look; anything else unrecognized
  # falls back to "intermediate" rather than left invalid.
  VALID_VALUES = %w[beginner intermediate advanced expert].freeze

  def up
    execute "UPDATE skills SET proficiency = 'advanced' WHERE proficiency = 'proficient'"
    execute <<~SQL.squish
      UPDATE skills SET proficiency = 'intermediate'
      WHERE proficiency NOT IN (#{VALID_VALUES.map { |v| connection.quote(v) }.join(', ')})
    SQL

    change_column_default :skills, :proficiency, from: 'proficient', to: 'intermediate'
  end

  def down
    change_column_default :skills, :proficiency, from: 'intermediate', to: 'proficient'
  end
end
