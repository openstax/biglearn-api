class Services::CreateEcosystem::Service
  def process(ecosystem_uuid:, book:, exercises:)

    book_container_attributes = book.fetch(:contents).map do |content|
      { uuid: content.fetch(:container_uuid) }
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
