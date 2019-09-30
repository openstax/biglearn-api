class AddCalculationUuidToExercisesAndClues < ActiveRecord::Migration[5.0]
  def change
    enable_extension :pgcrypto

    add_column :assignment_pes, :calculation_uuid, :uuid
    AssignmentPe.update_all '"calculation_uuid" = gen_random_uuid()'
    change_column_null :assignment_pes, :calculation_uuid, false
    add_index :assignment_pes,  :calculation_uuid

    add_column :assignment_spes, :calculation_uuid, :uuid
    AssignmentSpe.update_all '"calculation_uuid" = gen_random_uuid()'
    change_column_null :assignment_spes, :calculation_uuid, false
    add_index :assignment_spes,  :calculation_uuid

    add_column :student_pes, :calculation_uuid, :uuid
    StudentPe.update_all '"calculation_uuid" = gen_random_uuid()'
    change_column_null :student_pes, :calculation_uuid, false
    add_index :student_pes,  :calculation_uuid

    add_column :student_clues, :calculation_uuid, :uuid
    StudentClue.update_all '"calculation_uuid" = gen_random_uuid()'
    change_column_null :student_clues, :calculation_uuid, false
    add_index :student_clues,  :calculation_uuid

    add_column :teacher_clues, :calculation_uuid, :uuid
    TeacherClue.update_all '"calculation_uuid" = gen_random_uuid()'
    change_column_null :teacher_clues, :calculation_uuid, false
    add_index :teacher_clues,  :calculation_uuid
  end
end
