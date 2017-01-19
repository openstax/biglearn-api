class Services::CreateEcosystem::Service
  def process(ecosystem_uuid:, book:, exercises:)

    ecosystem = Ecosystem.new(
      uuid: ecosystem_uuid
    )

    # TODO: Save more stuff

    Ecosystem.transaction(isolation: :serializable) do
      Ecosystem.import [ecosystem], on_duplicate_key_ignore: true
    end

    { created_ecosystem_uuid: ecosystem_uuid }

  end
end
