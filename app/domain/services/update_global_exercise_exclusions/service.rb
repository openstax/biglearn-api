class Services::UpdateGlobalExerciseExclusions::Service < Services::ApplicationService
  def process(request_uuid:, course_uuid:, sequence_number:, ecosystem_uuid:, exclusions:, updated_at:)
    CourseEvent.append(
      uuid:            request_uuid,
      type:            :update_globally_excluded_exercises,
      course_uuid:     course_uuid,
      sequence_number: sequence_number,
      sequence_number_association_extra_attributes: {
        initial_ecosystem_uuid: ecosystem_uuid,
      },
      data:            {
        request_uuid: request_uuid,
        course_uuid:     course_uuid,
        sequence_number: sequence_number,
        exclusions: exclusions,
        updated_at: updated_at
      }
    )

    { status: 'success' }
  end
end
