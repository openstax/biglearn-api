class Services::CreateEcosystem::Service < Services::ApplicationService
  MAX_RETRIES = 3
  RETRY_DELAY = 1

  def process(ecosystem_uuid:, book:, exercises:, imported_at:)
    book_container_attributes = book.fetch(:contents).map do |content|
      { uuid: content.fetch(:container_uuid), ecosystem_uuid: ecosystem_uuid }
    end

    retries = 0
    begin
      Ecosystem.transaction do
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

        Ecosystem.create!(uuid: ecosystem_uuid)
      end
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => exception
      raise exception if retries >= MAX_RETRIES

      retries += 1
      log(:warn) { "#{exception.message.split("\n:").first}. Retry ##{retries}..." }
      sleep(RETRY_DELAY)
      retry
    end

    { created_ecosystem_uuid: ecosystem_uuid }
  end
end
