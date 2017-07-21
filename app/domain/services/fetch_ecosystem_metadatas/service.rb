class Services::FetchEcosystemMetadatas::Service < Services::ApplicationService
  def process
    ecosystem_uuids = EcosystemEvent.create_ecosystem.pluck(:ecosystem_uuid)

    ecosystem_responses = ecosystem_uuids.map { |ecosystem_uuid| { uuid: ecosystem_uuid } }

    { ecosystem_responses:  ecosystem_responses }
  end
end
