class GlobalExerciseExclusion < ActiveRecord::Base
  belongs_to :global_exercise_exclusion_updates, :foreign_key => 'update_uuid', :primary_key => 'update_uuid'
end
