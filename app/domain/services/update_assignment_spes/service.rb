class Services::UpdateAssignmentSpes::Service < Services::ApplicationService
  def process(spe_updates:)
    update_responses = []
    assignment_spes = spe_updates.map do |update|
      request_uuid = update.fetch(:request_uuid)

      update_responses << { request_uuid: request_uuid, update_status: 'accepted' }

      AssignmentSpe.new(
        uuid: request_uuid,
        calculation_uuid: update[:calculation_uuid],
        ecosystem_matrix_uuid: update[:ecosystem_matrix_uuid],
        assignment_uuid: update.fetch(:assignment_uuid),
        algorithm_name: update.fetch(:algorithm_name),
        exercise_uuids: update.fetch(:exercise_uuids),
        spy_info: update.fetch(:spy_info, {})
      )
    end

    AssignmentSpe.import assignment_spes, validate: false, on_duplicate_key_update: {
      conflict_target: [ :assignment_uuid, :algorithm_name ],
      columns: [ :uuid, :calculation_uuid, :ecosystem_matrix_uuid, :exercise_uuids, :spy_info ]
    }

    { spe_update_responses: update_responses }
  end
end
