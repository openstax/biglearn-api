class AddCalculationUuidAndEcosystemMatrixUuidToExercisesAndClues < ActiveRecord::Migration[5.2]
  NIL_UUID = '00000000-0000-0000-0000-000000000000'

  def change
    add_column :assignment_pes, :calculation_uuid, :uuid
    change_column_null :assignment_pes, :calculation_uuid, false, NIL_UUID
    add_index :assignment_pes, :calculation_uuid

    add_column :assignment_pes, :ecosystem_matrix_uuid, :uuid
    change_column_null :assignment_pes, :ecosystem_matrix_uuid, false, NIL_UUID
    add_index :assignment_pes, :ecosystem_matrix_uuid

    add_column :assignment_spes, :calculation_uuid, :uuid
    change_column_null :assignment_spes, :calculation_uuid, false, NIL_UUID
    add_index :assignment_spes, :calculation_uuid

    add_column :assignment_spes, :ecosystem_matrix_uuid, :uuid
    change_column_null :assignment_spes, :ecosystem_matrix_uuid, false, NIL_UUID
    add_index :assignment_spes, :ecosystem_matrix_uuid

    add_column :student_pes, :calculation_uuid, :uuid
    change_column_null :student_pes, :calculation_uuid, false, NIL_UUID
    add_index :student_pes, :calculation_uuid

    add_column :student_pes, :ecosystem_matrix_uuid, :uuid
    change_column_null :student_pes, :ecosystem_matrix_uuid, false, NIL_UUID
    add_index :student_pes, :ecosystem_matrix_uuid

    add_column :student_clues, :calculation_uuid, :uuid
    change_column_null :student_clues, :calculation_uuid, false, NIL_UUID
    add_index :student_clues, :calculation_uuid

    add_column :teacher_clues, :calculation_uuid, :uuid
    change_column_null :teacher_clues, :calculation_uuid, false, NIL_UUID
    add_index :teacher_clues, :calculation_uuid
  end
end
