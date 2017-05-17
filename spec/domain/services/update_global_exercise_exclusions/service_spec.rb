require 'rails_helper'

RSpec.describe Services::UpdateGlobalExerciseExclusions::Service, type: :service do
  include ExerciseExclusionsServicesSharedExamples

  include_examples "update exercise exclusions services", :update_globally_excluded_exercises
end
