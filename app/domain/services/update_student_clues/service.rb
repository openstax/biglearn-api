class Services::UpdateStudentClues::Service < Services::ApplicationService
  def process(student_clue_updates:)
    update_responses = []
    student_clues = student_clue_updates.map do |update|
      request_uuid = update.fetch(:request_uuid)
      clue_data = update.fetch(:clue_data)

      update_responses << { request_uuid: request_uuid, update_status: 'accepted' }

      StudentClue.new(
        uuid: request_uuid,
        calculation_uuid: update[:calculation_uuid],
        student_uuid: update.fetch(:student_uuid),
        book_container_uuid: update.fetch(:book_container_uuid),
        algorithm_name: update.fetch(:algorithm_name),
        data: clue_data
      )
    end

    StudentClue.import student_clues, validate: false, on_duplicate_key_update: {
      conflict_target: [ :student_uuid, :book_container_uuid, :algorithm_name ],
      columns: [ :uuid, :calculation_uuid, :data ]
    }

    { student_clue_update_responses: update_responses }
  end
end
