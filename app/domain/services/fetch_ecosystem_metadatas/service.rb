class Services::FetchEcosystemMetadatas::Service < Services::ApplicationService
  def process(metadata_sequence_number_offset:, max_num_metadatas:)
    ee = Ecosystem.arel_table
    ecosystems = Ecosystem
      .where(ee[:metadata_sequence_number].gteq(metadata_sequence_number_offset))
      .order(:metadata_sequence_number)
      .limit(max_num_metadatas)
      .pluck_with_keys(:uuid, :metadata_sequence_number)

    ecosystem_responses = ecosystems.map do |ecosystem|
      { uuid: ecosystem[:uuid], metadata_sequence_number: ecosystem[:metadata_sequence_number] }
    end

    { ecosystem_responses:  ecosystem_responses }
  end
end
