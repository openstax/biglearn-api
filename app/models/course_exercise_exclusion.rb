class CourseExerciseExclusion < ActiveRecord::Base
  validates :sequence_number, :numericality => { :greater_than_or_equal_to => 0 }
end
