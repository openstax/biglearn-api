class Services::UpdateCourseActiveDates::Service
  def process(course_uuid:, sequence_number:, starts_at:, ends_at:)
    CourseEvent.append(
      uuid: SecureRandom.uuid,
      type: :update_course_active_dates,
      course_uuid: course_uuid,
      sequence_number: sequence_number,
      data: { starts_at: starts_at, ends_at: ends_at }
    )

    { updated_course_uuid: course_uuid }
  end
end
