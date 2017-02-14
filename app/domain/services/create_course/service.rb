class Services::CreateCourse::Service
  def process(course_uuid:, ecosystem_uuid:)

    CourseEvent.append(
      uuid: course_uuid,
      type: :create_course,
      course_uuid: course_uuid,
      sequence_number: 0,
      data: { ecosystem_uuid: ecosystem_uuid }
    )

    { created_course_uuid: course_uuid }
  end
end
