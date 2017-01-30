require 'rails_helper'

RSpec.describe Services::UpdateGlobalExerciseExclusions::Service, type: :service do
  include ExerciseExclusionsServicesSharedExamples

  GLOBAL_ACTION_PROC = lambda do |request_uuid:, sequence_number:, exclusions:|
    described_class.new.process(
      request_uuid:    request_uuid,
      sequence_number: sequence_number,
      exclusions:      exclusions
    )
  end

  include_examples "update exercise exclusions services",
                   GlobalExerciseExclusion,
                   GLOBAL_ACTION_PROC
end
