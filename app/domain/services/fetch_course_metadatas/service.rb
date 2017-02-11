class Services::FetchCourseMetadatas::Service
  def process
    { course_metadatas: Course.pluck_with_keys(:uuid) }
  end
end
