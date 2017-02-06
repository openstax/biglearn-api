class Services::UpdateCourseExerciseExclusions::Service
  def process(request_uuid:, course_uuid:, sequence_number:, exclusions:)
    CourseEvent.append(
      uuid:            request_uuid,
      type:            :update_course_exercise_exclusions,
      course_uuid:     course_uuid,
      sequence_number: sequence_number,
      data:            { request_uuid: request_uuid, exclusions: exclusions }
    )

    { status: 'success' }
  end
end
