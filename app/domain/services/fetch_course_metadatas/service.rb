class Services::FetchCourseMetadatas::Service
  def process
    { course_responses: Course.pluck_with_keys({
      uuid: :uuid,
      ecosystem_uuid: :initial_ecosystem_uuid
    }) }
  end
end
