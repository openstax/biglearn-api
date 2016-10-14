class CreateCourseExerciseExclusionUpdates < ActiveRecord::Migration
  def change
    create_table :course_exercise_exclusion_updates do |t|
      t.uuid          :update_uuid,                         null: false
      t.integer       :sequence_number,                     null: false
      t.uuid          :course_uuid,                         null: false

      t.timestamps                                          null: false
    end
    add_index         :course_exercise_exclusion_updates,   [:course_uuid, :sequence_number],
                                                            unique: true,
                                                            name: 'index_course_exclusions_by_course_and_sequence'
    add_index         :course_exercise_exclusion_updates,   :update_uuid,
                                                            unique: true
  end
end
