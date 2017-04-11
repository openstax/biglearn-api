class Services::FetchEcosystemMetadatas::Service
  def process
    ecosystems = EcosystemEvent.create_ecosystem
                               .distinct
                               .order(:created_at)
                               .pluck_with_keys(:ecosystem_uuid, :data, :created_at)

    ecosystem_responses = ecosystems.map do |ecosystem|
      {
        uuid: ecosystem[:ecosystem_uuid],
        cnx_identity: ecosystem[:data].deep_symbolize_keys.fetch(:book).fetch(:cnx_identity)
      }
    end

    { ecosystem_responses:  ecosystem_responses}
  end
end
