class Services::UpdatePracticeWorstAreasExercises::Service < Services::ApplicationService
  def process(practice_worst_areas_updates:)
    update_responses = []
    student_pes = practice_worst_areas_updates.map do |update|
      request_uuid = update.fetch(:request_uuid)

      update_responses << { request_uuid: request_uuid, update_status: 'accepted' }

      StudentPe.new(
        uuid: request_uuid,
        student_uuid: update.fetch(:student_uuid),
        algorithm_name: update.fetch(:algorithm_name),
        exercise_uuids: update.fetch(:exercise_uuids),
        spy_info: update.fetch(:spy_info, {})
      )
    end

    StudentPe.import student_pes, validate: false, on_duplicate_key_update: {
      conflict_target: [ :student_uuid, :algorithm_name ],
      columns: [ :uuid, :exercise_uuids, :spy_info ]
    }

    { practice_worst_areas_update_responses: update_responses }
  end
end
