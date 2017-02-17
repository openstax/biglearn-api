class Services::UpdateAssignmentPes::Service
  def process(pe_updates:)
    update_responses = []
    assignment_pes = pe_updates.map do |update|
      request_uuid = update.fetch(:request_uuid)

      update_responses << { request_uuid: request_uuid, update_status: 'accepted' }

      AssignmentPe.new(
        uuid: request_uuid,
        assignment_uuid: update.fetch(:assignment_uuid),
        exercise_uuids: update.fetch(:exercise_uuids)
      )
    end

    AssignmentPe.import assignment_pes, validate: false, on_duplicate_key_update: {
      conflict_target: [:assignment_uuid],
      columns: [ :uuid, :exercise_uuids ]
    }

    { pe_update_responses: update_responses }
  end
end
