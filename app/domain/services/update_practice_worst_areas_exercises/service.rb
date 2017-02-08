class Services::UpdatePracticeWorstAreasExercises::Service
  def process(practice_worst_area_updates:)
    update_responses = []
    student_pes = practice_worst_area_updates.map do |update|

      update_responses << { request_uuid: update[:request_uuid], update_status: 'accepted' }

      StudentPe.new(
        uuid: update[:request_uuid],
        student_uuid: update[:student_uuid],
        exercise_uuids: update[:exercise_uuids]
      )
    end

    StudentPe.import student_pes, validate: false, on_duplicate_key_update: {
      conflict_target: [:student_uuid],
      columns: [
        :uuid,
        :exercise_uuids
      ]
    }

    { practice_worst_area_update_responses: update_responses }
  end
end