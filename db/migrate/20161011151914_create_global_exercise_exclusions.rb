class CreateGlobalExerciseExclusions < ActiveRecord::Migration
  def change
    create_table :global_exercise_exclusions do |t|
      t.uuid          :update_uuid,                 null: false
      t.uuid          :excluded_uuid,               null: false

      t.timestamps                                  null: false
    end
  end
end
