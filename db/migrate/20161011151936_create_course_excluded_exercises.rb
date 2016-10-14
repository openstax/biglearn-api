class CreateCourseExcludedExercises < ActiveRecord::Migration
  def change
    create_table :course_excluded_exercises do |t|
      t.integer       :sequence_number,           null: false
      t.uuid          :course_uuid,               null: false
      t.uuid          :excluded_uuid,             null: false

      t.timestamps                                null: false
    end
  end
end
