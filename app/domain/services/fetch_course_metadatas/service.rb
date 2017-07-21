class Services::FetchCourseMetadatas::Service < Services::ApplicationService
  def process
    courses = CourseEvent.create_course.pluck_with_keys(:course_uuid, :data)

    course_responses = courses.map do |course|
      {
        uuid: course[:course_uuid],
        initial_ecosystem_uuid: course[:data].symbolize_keys.fetch(:ecosystem_uuid)
      }
    end

    { course_responses:  course_responses }
  end
end
