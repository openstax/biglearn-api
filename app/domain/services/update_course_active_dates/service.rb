class Services::UpdateCourseActiveDates::Service
  def process(course_uuid:, sequence_number:, starts_at:, ends_at:)
    course_active_date = CourseActiveDate.new(
      uuid: SecureRandom.uuid,
      course_uuid: course_uuid,
      sequence_number: sequence_number,
      starts_at: starts_at,
      ends_at: ends_at
    )

    CourseActiveDate.import [course_active_date], on_duplicate_key_ignore: true

    { updated_course_uuid: course_uuid }
  end
end
