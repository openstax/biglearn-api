class CourseExerciseExclusion < ActiveRecord::Base
  belongs_to :course_exercise_exclusion_updates, :foreign_key => 'update_uuid', :primary_key => 'update_uuid'
end
