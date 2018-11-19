class AddSequenceNumberToEcosystemsAndCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :ecosystems, :sequence_number, :integer, null: false, default: 0
    add_column :courses, :sequence_number, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Ecosystem.reset_column_information
        Ecosystem.update_all <<-UPDATE_SQL.strip_heredoc
          "sequence_number" = (
            SELECT COALESCE(MAX("ecosystem_events"."sequence_number"), -1) + 1
            FROM "ecosystem_events"
            WHERE "ecosystem_events"."ecosystem_uuid" = "ecosystems"."uuid"
          )
        UPDATE_SQL

        Course.reset_column_information
        Course.update_all <<-UPDATE_SQL.strip_heredoc
          "sequence_number" = (
            SELECT COALESCE(MAX("course_events"."sequence_number"), -1) + 1
            FROM "course_events"
            WHERE "course_events"."course_uuid" = "courses"."uuid"
          )
        UPDATE_SQL
      end
    end

    add_index :ecosystems, :sequence_number
    add_index :courses, :sequence_number
  end
end
