class CreateAssignmentPes < ActiveRecord::Migration
  def change
    create_table :assignment_pes do |t|
      t.uuid   :uuid,            null: false, index: { unique: true }
      t.uuid   :assignment_uuid, null: false
      t.string :algorithm_name,  null: false
      t.uuid   :exercise_uuids,  null: false, array: true

      t.timestamps               null: false
    end

    add_index :assignment_pes, [:assignment_uuid, :algorithm_name], unique: true
  end
end
