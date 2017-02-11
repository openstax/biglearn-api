class Services::FetchCourseMetadatas::Service
  def process
    { course_responses: Course.pluck_with_keys(:uuid) }
  end
end
