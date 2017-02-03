class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.uuid :uuid,                            null: false, index: { unique: true }
      t.uuid :assignment_uuid,                 null: false
      t.integer :sequence_number,              null: false
      t.boolean :is_deleted,                   null: false
      t.uuid :ecosystem_uuid,                  null: false, index: true
      t.uuid :student_uuid,                    null: false, index: true
      t.string :assignment_type,               null: false
      t.datetime :opens_at
      t.datetime :due_at
      t.uuid :assigned_book_container_uuids,   null: false, array: true
      t.integer :goal_num_tutor_assigned_spes, null: false
      t.boolean :spes_are_assigned,            null: false
      t.integer :goal_num_tutor_assigned_pes,  null: false
      t.boolean :pes_are_assigned,             null: false

      t.timestamps                             null: false
    end

    add_index :assignments, [:assignment_uuid, :sequence_number], unique: true
  end
end
