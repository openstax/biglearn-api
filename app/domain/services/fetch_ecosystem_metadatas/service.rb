class Services::FetchEcosystemMetadatas::Service
  def process
    { ecosystem_metadatas: Ecosystem.pluck_with_keys(:uuid) }
  end
end
