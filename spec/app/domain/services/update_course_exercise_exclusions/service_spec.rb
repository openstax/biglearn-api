require 'rails_helper'

RSpec.describe Services::UpdateCourseExerciseExclusions::Service, type: :service do
  include ExerciseExclusionsServicesSharedExamples

  include_examples "update exercise exclusions services", :update_course_excluded_exercises
end
