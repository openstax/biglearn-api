class CreateAssignmentSpes < ActiveRecord::Migration
  def change
    create_table :assignment_spes do |t|
      t.uuid :uuid,            null: false, index: { unique: true }
      t.uuid :assignment_uuid, null: false, index: { unique: true }
      t.uuid :exercise_uuids,  null: false, array: true

      t.timestamps             null: false
    end
  end
end
