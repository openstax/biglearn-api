class CreateStudentPes < ActiveRecord::Migration
  def change
    create_table :student_pes do |t|
      t.uuid :uuid,           null: false, index: { unique: true }
      t.uuid :student_uuid,   null: false, index: { unique: true }
      t.uuid :exercise_uuids, null: false, array: true

      t.timestamps            null: false
    end
  end
end