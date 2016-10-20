class CreateCourseExerciseExclusions < ActiveRecord::Migration
  def change
    create_table :course_exercise_exclusions do |t|
      t.uuid          :update_uuid,                 null: false
      t.uuid          :excluded_uuid,               null: false

      t.timestamps                                  null: false
    end
  end
end
