class CreateGlobalExerciseExclusions < ActiveRecord::Migration
  def change
    create_table :global_exercise_exclusions do |t|
      t.uuid :uuid,                          null: false, index: { unique: true }
      t.integer :sequence_number,            null: false, index: { unique: true }
      t.uuid :excluded_exercise_uuids,       null: false, array: true
      t.uuid :excluded_exercise_group_uuids, null: false, array: true

      t.timestamps                           null: false
    end
  end
end
