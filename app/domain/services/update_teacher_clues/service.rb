class Services::UpdateTeacherClues::Service < Services::ApplicationService
  def process(teacher_clue_updates:)
    update_responses = []
    teacher_clues = teacher_clue_updates.map do |update|
      request_uuid = update.fetch(:request_uuid)
      clue_data = update.fetch(:clue_data)

      update_responses << { request_uuid: request_uuid, update_status: 'accepted' }

      TeacherClue.new(
        uuid: request_uuid,
        course_container_uuid: update.fetch(:course_container_uuid),
        book_container_uuid: update.fetch(:book_container_uuid),
        algorithm_name: update.fetch(:algorithm_name),
        data: clue_data
      )
    end

    TeacherClue.import teacher_clues, validate: false, on_duplicate_key_update: {
      conflict_target: [ :course_container_uuid, :book_container_uuid, :algorithm_name ],
      columns: [ :uuid, :data ]
    }

    { teacher_clue_update_responses: update_responses }
  end
end
