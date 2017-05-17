class Services::CreateEcosystem::Service < Services::ApplicationService
  def process(ecosystem_uuid:, book:, exercises:, imported_at:)

    book_container_attributes = book.fetch(:contents).map do |content|
      { uuid: content.fetch(:container_uuid), ecosystem_uuid: ecosystem_uuid }
    end

    EcosystemEvent.transaction do
      BookContainer.append book_container_attributes

      EcosystemEvent.append(
        uuid: ecosystem_uuid,
        type: :create_ecosystem,
        ecosystem_uuid: ecosystem_uuid,
        sequence_number: 0,
        data: {
          ecosystem_uuid: ecosystem_uuid,
          sequence_number: 0,
          book: book,
          exercises: exercises,
          imported_at: imported_at
        }
      )
    end

    { created_ecosystem_uuid: ecosystem_uuid }

  end
end
