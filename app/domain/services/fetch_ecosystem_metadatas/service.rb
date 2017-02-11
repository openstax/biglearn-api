class Services::FetchEcosystemMetadatas::Service
  def process
    { ecosystem_responses: Ecosystem.pluck_with_keys(:uuid) }
  end
end
