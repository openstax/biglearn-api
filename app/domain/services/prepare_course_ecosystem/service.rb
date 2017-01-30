class Services::PrepareCourseEcosystem::Service
  def process(preparation_uuid:, course_uuid:, sequence_number:,
              next_ecosystem_uuid:, ecosystem_map:)
    create_ecosystem_map(ecosystem_map: ecosystem_map)

    create_ecosystem_preparation(
      uuid: preparation_uuid,
      course_uuid: course_uuid,
      sequence_number: sequence_number,
      ecosystem_uuid: next_ecosystem_uuid
    )

    { status: 'accepted' }
  end

  protected

  def create_ecosystem_map(ecosystem_map:)
    map = EcosystemMap.new(
      uuid: SecureRandom.uuid,
      from_ecosystem_uuid: ecosystem_map[:from_ecosystem_uuid],
      to_ecosystem_uuid: ecosystem_map[:to_ecosystem_uuid],
      cnx_pagemodule_mappings: ecosystem_map[:cnx_pagemodule_mappings],
      exercise_mappings: ecosystem_map[:cnx_pagemodule_mappings]
    )

    EcosystemMap.transaction(isolation: :serializable) do
      EcosystemMap.import [map], on_duplicate_key_ignore: true
    end
  end

  def create_ecosystem_preparation(uuid:, course_uuid:, sequence_number:, ecosystem_uuid:)
    ecosystem_preparation = EcosystemPreparation.new(
      uuid: uuid,
      course_uuid: course_uuid,
      sequence_number: sequence_number,
      ecosystem_uuid: ecosystem_uuid
    )

    EcosystemPreparation.transaction(isolation: :serializable) do
      EcosystemPreparation.import [ecosystem_preparation], on_duplicate_key_ignore: true
    end
  end
end
