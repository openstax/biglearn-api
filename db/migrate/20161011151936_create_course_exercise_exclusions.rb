class CreateCourseExerciseExclusions < ActiveRecord::Migration
  def change
    create_table :course_exercise_exclusions do |t|
      t.integer       :sequence_number,           null: false
      t.uuid          :course_uuid,               null: false
      t.uuid          :excluded_uuid,             null: false

      t.timestamps                                null: false
    end
  end
end
