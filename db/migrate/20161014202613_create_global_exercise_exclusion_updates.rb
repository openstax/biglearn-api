class CreateGlobalExerciseExclusionUpdates < ActiveRecord::Migration
  def change
    create_table :global_exercise_exclusion_updates do |t|
      t.uuid          :update_uuid,                         null: false
      t.integer       :sequence_number,                     null: false

      t.timestamps                                          null: false
    end
    add_index         :global_exercise_exclusion_updates,   :sequence_number,
                                                            unique: true
    add_index         :global_exercise_exclusion_updates,   :update_uuid,
                                                            unique: true
  end
end
