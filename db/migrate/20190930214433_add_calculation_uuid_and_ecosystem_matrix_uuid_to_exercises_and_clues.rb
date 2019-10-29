class AddCalculationUuidAndEcosystemMatrixUuidToExercisesAndClues < ActiveRecord::Migration[5.2]
  NIL_UUID = '00000000-0000-0000-0000-000000000000'

  def change
    add_column :assignment_pes, :calculation_uuid, :uuid
    add_column :assignment_pes, :ecosystem_matrix_uuid, :uuid
    add_column :assignment_spes, :calculation_uuid, :uuid
    add_column :assignment_spes, :ecosystem_matrix_uuid, :uuid
    add_column :student_pes, :calculation_uuid, :uuid
    add_column :student_pes, :ecosystem_matrix_uuid, :uuid
    add_column :student_clues, :calculation_uuid, :uuid
    add_column :teacher_clues, :calculation_uuid, :uuid

    reversible do |dir|
      dir.up do
        # A simple background migration with the drawback that it will not retry errors
        background_migration = -> do
          # Become a daemon so the calling process can exit successfully
          Process.daemon

          change_column_null :assignment_pes, :calculation_uuid, false, NIL_UUID
          change_column_null :assignment_pes, :ecosystem_matrix_uuid, false, NIL_UUID
          change_column_null :assignment_spes, :calculation_uuid, false, NIL_UUID
          change_column_null :assignment_spes, :ecosystem_matrix_uuid, false, NIL_UUID
          change_column_null :student_pes, :calculation_uuid, false, NIL_UUID
          change_column_null :student_pes, :ecosystem_matrix_uuid, false, NIL_UUID
          change_column_null :student_clues, :calculation_uuid, false, NIL_UUID
          change_column_null :teacher_clues, :calculation_uuid, false, NIL_UUID

          add_index :assignment_pes, :calculation_uuid
          add_index :assignment_pes, :ecosystem_matrix_uuid
          add_index :assignment_spes, :calculation_uuid
          add_index :assignment_spes, :ecosystem_matrix_uuid
          add_index :student_pes, :calculation_uuid
          add_index :student_pes, :ecosystem_matrix_uuid
          add_index :student_clues, :calculation_uuid
          add_index :teacher_clues, :calculation_uuid

          # Need to manually dump the schema or else it will become stale
          Rake::Task['db:_dump'].invoke
        end

        # This code will run after all foreground migrations have finished
        at_exit { background_migration.call }
      end
    end
  end
end
