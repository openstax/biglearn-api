require 'rails_helper'

RSpec.describe Services::UpdateCourseExerciseExclusions::Service, type: :service do
  include ExerciseExclusionsServicesSharedExamples

  GIVEN_COURSE_UUID = SecureRandom.uuid

  COURSE_ACTION_PROC = lambda do |request_uuid:, sequence_number:, exclusions:|
    described_class.new.process(
      request_uuid:    request_uuid,
      course_uuid:     GIVEN_COURSE_UUID,
      sequence_number: sequence_number,
      exclusions:      exclusions
    )
  end

  COURSE_ATTR_CHECK_PROC = ->(new_model) { new_model.course_uuid == GIVEN_COURSE_UUID }

  include_examples "update exercise exclusions services",
                   CourseExerciseExclusion,
                   COURSE_ACTION_PROC,
                   COURSE_ATTR_CHECK_PROC
end
