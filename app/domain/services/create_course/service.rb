class Services::CreateCourse::Service < Services::ApplicationService
  def process(course_uuid:, ecosystem_uuid:, is_real_course:, starts_at:, ends_at:, created_at:)
    CourseEvent.append(
      uuid: course_uuid,
      type: :create_course,
      course_uuid: course_uuid,
      sequence_number: 0,
      data: {
        course_uuid: course_uuid,
        sequence_number: 0,
        ecosystem_uuid: ecosystem_uuid,
        is_real_course: is_real_course,
        starts_at: starts_at,
        ends_at: ends_at,
        created_at: created_at
      }
    )

    { created_course_uuid: course_uuid }
  end
end
