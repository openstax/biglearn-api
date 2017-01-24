class Services::PrepareCourseEcosystem::Service
  def process(preparation_uuid:, course_uuid:, sequence_number:,
              next_ecosystem_uuid:, ecosystem_map:)
    map = find_or_create_ecosystem_map(ecosystem_map: ecosystem_map)

    EcosystemPreparation.create(
      uuid: preparation_uuid,
      course_uuid: course_uuid,
      sequence_number: sequence_number,
      ecosystem_uuid: next_ecosystem_uuid,
      ecosystem_map: map
    )
  end

  protected

  def find_or_create_ecosystem_map(ecosystem_map:)
    map = EcosystemMap.new(
      from_ecosystem_uuid: ecosystem_map[:from_ecosystem_uuid],
      to_ecosystem_uuid: ecosystem_map[:to_ecosystem_uuid],
      cnx_pagemodule_mappings: ecosystem_map[:cnx_pagemodule_mappings],
      exercise_mappings: ecosystem_map[:cnx_pagemodule_mappings]
    )

    EcosystemMap.transaction(isolation: :serializable) do
      result = EcosystemMap.import [map], on_duplicate_key_ignore: true

      if result.failed_instances.include?(map)
        # Abort the import completely if the map already exists
        # THIS CODE WILL NEED CHANGES IF WE STOP USING SERIALIZABLE ISOLATION
        # If not using serializable, we could use ON CONFLICT UPDATE and update only some
        # meaningless column, like updated_at, which would cause the INSERT to return the record
        map = EcosystemMap.find_by(
          from_ecosystem_uuid: from_ecosystem_uuid, to_ecosystem_uuid: to_ecosystem_uuid
        )

        # Import failed, but record not already in DB so something weird happened
        raise ActiveRecord::RecordNotSaved if map.nil?
      end
    end

    map
  end
end
