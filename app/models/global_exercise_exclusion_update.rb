class GlobalExerciseExclusionUpdate < ActiveRecord::Base
  validates :sequence_number, :numericality => { :greater_than_or_equal_to => 0 }
  has_many :global_exercise_exclusion, :foreign_key => 'update_uuid', :primary_key => 'update_uuid'
end
