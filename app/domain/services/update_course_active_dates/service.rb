class Services::UpdateCourseActiveDates::Service
  def process(request_uuid:, course_uuid:, sequence_number:, starts_at:, ends_at:)
    CourseEvent.append(
      uuid: request_uuid,
      type: :update_course_active_dates,
      course_uuid: course_uuid,
      sequence_number: sequence_number,
      data: {
        request_uuid: request_uuid,
        course_uuid: course_uuid,
        sequence_number: sequence_number,
        starts_at: starts_at,
        ends_at: ends_at
      }
    )

    { updated_course_uuid: course_uuid }
  end
end
