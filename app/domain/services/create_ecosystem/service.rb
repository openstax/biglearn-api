class Services::CreateEcosystem::Service
  def process(ecosystem_uuid:, book:, exercises:)

    create_exercises(exercises: exercises)

    book_model = create_or_find_book(book: book)

    create_ecosystem(ecosystem_uuid: ecosystem_uuid, book_model: book_model)

    { created_ecosystem_uuid: ecosystem_uuid }

  end

  protected

  def create_exercises(exercises:)
    exercise_models = exercises.map do |exercise_hash|
      Exercise.new(
        uuid: exercise_hash[:uuid],
        exercises_uuid: exercise_hash[:exercises_uuid],
        exercises_version: exercise_hash[:exercises_version],
        los: exercise_hash[:los]
      )
    end

    Exercise.transaction(isolation: :serializable) do
      Exercise.import exercise_models, on_duplicate_key_ignore: true
    end
  end

  # Returns the book model
  def create_or_find_book(book:)
    book_model = Book.new(
      uuid: SecureRandom.uuid,
      cnx_identity: book[:cnx_identity]
    )

    Book.transaction(isolation: :serializable) do
      result = Book.import [book_model], on_duplicate_key_ignore: true

      if result.failed_instances.include?(book_model)
        # Abort the import completely if the book already exists
        # The serializable isolation level should ensure that
        # we find the inserted record here if the INSERT failed above
        # If not using serializable, we could use ON CONFLICT UPDATE and update only some
        # meaningless column, like updated_at, which would cause the INSERT to return the record
        book_model = Book.find_by(cnx_identity: book[:cnx_identity])

        # Import failed, but record not already in DB so something weird happened
        raise ActiveRecord::RecordNotSaved if book_model.nil?

        return book_model
      end

      # If the insert succeeds, continue creating the book content in the same transaction
      # We are now sure that nobody else beat us to creating this book
      book_containers = book[:contents].map do |container_hash|
        BookContainer.new(
          uuid: container_hash[:container_uuid],
          book: book_model,
          parent_uuid: container_hash[:container_parent_uuid],
          cnx_identity: container_hash[:container_cnx_identity]
        )
      end

      # On duplicate key: raise exception (these book containers should not exist yet)
      BookContainer.import book_containers

      exercise_pools = book[:contents].flat_map do |container_hash|
        container_hash[:pools].map do |pool_hash|
          assignment_types = pool_hash[:use_for_personalized_for_assignment_types]

          ExercisePool.new(
            uuid: SecureRandom.uuid,
            container_uuid: container_hash[:container_uuid],
            use_for_clue: pool_hash[:use_for_clue],
            use_for_personalized_for_assignment_types: assignment_types,
            exercise_uuids: pool_hash[:exercise_uuids]
          )
        end
      end

      # On duplicate key: raise exception (these exercise pools should not exist yet)
      ExercisePool.import exercise_pools
    end

    book_model
  end

  def create_ecosystem(ecosystem_uuid:, book_model:)
    ecosystem_model = Ecosystem.new(
      uuid: ecosystem_uuid,
      book: book_model
    )

    Ecosystem.transaction(isolation: :serializable) do
      Ecosystem.import [ecosystem_model], on_duplicate_key_ignore: true
    end
  end
end
