class Services::FetchCourseMetadatas::Service < Services::ApplicationService
  def process(metadata_sequence_number_offset:, max_num_metadatas:)
    cc = Course.arel_table
    courses = Course
      .where(cc[:metadata_sequence_number].gteq(metadata_sequence_number_offset))
      .where(cc[:initial_ecosystem_uuid].not_eq(nil))
      .order(:metadata_sequence_number)
      .limit(max_num_metadatas)
      .pluck_with_keys(:uuid, :initial_ecosystem_uuid, :metadata_sequence_number)

    course_responses = courses.map do |course|
      {
        uuid: course[:uuid],
        initial_ecosystem_uuid: course[:initial_ecosystem_uuid],
        metadata_sequence_number: course[:metadata_sequence_number]
      }
    end

    { course_responses:  course_responses }
  end
end
