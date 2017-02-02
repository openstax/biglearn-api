class Services::UpdateTeacherClues::Service
  def process(teacher_clue_updates:)
    update_responses = []
    teacher_clues = teacher_clue_updates.map do |update|
      clue_data = update[:clue_data]
      confidence = clue_data[:confidence]
      interpretation = clue_data[:interpretation]

      update_responses << { request_uuid: update[:request_uuid], update_status: 'accepted' }

      TeacherClue.new(
        uuid: update[:request_uuid],
        course_container_uuid: update[:course_container_uuid],
        book_container_uuid: update[:book_container_uuid],
        aggregate: clue_data[:aggregate],
        confidence_left: confidence[:left],
        confidence_right: confidence[:right],
        sample_size: confidence[:sample_size],
        unique_learner_count: confidence[:unique_learner_count],
        is_good_confidence: interpretation[:confidence] == 'good',
        is_high_level: interpretation[:level] == 'high',
        is_above_threshold: interpretation[:threshold] == 'above'
      )
    end

    TeacherClue.import teacher_clues, validate: false, on_duplicate_key_update: {
      conflict_target: [:course_container_uuid, :book_container_uuid],
      columns: [
        :uuid,
        :aggregate,
        :confidence_left,
        :confidence_right,
        :sample_size,
        :unique_learner_count,
        :is_good_confidence,
        :is_high_level,
        :is_above_threshold
      ]
    }

    { teacher_clue_update_responses: update_responses }
  end
end
