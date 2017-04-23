class Services::FetchEcosystemMetadatas::Service
  def process
    ecosystems = EcosystemEvent.create_ecosystem
                               .distinct
                               .order(:created_at)
                               .pluck_with_keys(:ecosystem_uuid, :created_at)

    ecosystem_responses = ecosystems.map { |ecosystem| { uuid: ecosystem[:ecosystem_uuid] } }

    { ecosystem_responses:  ecosystem_responses }
  end
end
