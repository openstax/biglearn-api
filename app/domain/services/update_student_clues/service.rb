class Services::UpdateStudentClues::Service
  def process(student_clue_updates:)
    update_responses = []
    student_clues = student_clue_updates.map do |update|
      clue_data = update[:clue_data]
      confidence = clue_data[:confidence]
      interpretation = clue_data[:interpretation]

      update_responses << { request_uuid: update[:request_uuid], update_status: 'accepted' }

      StudentClue.new(
        uuid: update[:request_uuid],
        student_uuid: update[:student_uuid],
        book_container_uuid: update[:book_container_uuid],
        aggregate: clue_data[:aggregate],
        confidence_left: confidence[:left],
        confidence_right: confidence[:right],
        sample_size: confidence[:sample_size],
        is_good_confidence: interpretation[:confidence] == 'good',
        is_high_level: interpretation[:level] == 'high',
        is_above_threshold: interpretation[:threshold] == 'above'
      )
    end

    StudentClue.import student_clues, validate: false, on_duplicate_key_update: {
      conflict_target: [:student_uuid, :book_container_uuid],
      columns: [
        :uuid,
        :aggregate,
        :confidence_left,
        :confidence_right,
        :sample_size,
        :is_good_confidence,
        :is_high_level,
        :is_above_threshold
      ]
    }

    { student_clue_update_responses: update_responses }
  end
end
