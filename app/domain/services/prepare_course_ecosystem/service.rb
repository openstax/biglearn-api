class Services::PrepareCourseEcosystem::Service
  def process(preparation_uuid:, course_uuid:, sequence_number:,
              next_ecosystem_uuid:, ecosystem_map:)
    CourseEvent.append(
      type: :prepare_course_ecosystem,
      uuid: preparation_uuid,
      course_uuid: course_uuid,
      sequence_number: sequence_number,
      data: {
        preparation_uuid: preparation_uuid,
        ecosystem_uuid: next_ecosystem_uuid,
        ecosystem_map: ecosystem_map
      }
    )

    { status: 'accepted' }
  end
end
