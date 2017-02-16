class Services::FetchCourseMetadatas::Service
  def process
    courses = CourseEvent.create_course.uniq.order(:created_at)
                                .pluck_with_keys(:course_uuid, :data, :created_at)

    course_responses = courses.map{ |course|
      {
        uuid: course[:course_uuid],
        initial_ecosystem_uuid: course[:data].deep_symbolize_keys.fetch(:ecosystem_uuid)
      }
    }

    { course_responses:  course_responses}
  end
end
