class Services::CreateEcosystem::Service
  def process(ecosystem_uuid:, book:, exercises:)

    book_container_attributes = book[:book_containers].map do |book_container|
      { uuid: book_container[:container_uuid] }
    end

    EcosystemEvent.transaction(isolation: :serializable) do
      BookContainer.append book_container_attributes

      EcosystemEvent.append(
        uuid: ecosystem_uuid,
        type: :create_ecosystem,
        ecosystem_uuid: ecosystem_uuid,
        sequence_number: 0,
        data: { book: book, exercises: exercises }
      )
    end

    { created_ecosystem_uuid: ecosystem_uuid }

  end
end
