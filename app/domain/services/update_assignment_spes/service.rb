class Services::UpdateAssignmentSpes::Service
  def process(spe_updates:)
    update_responses = []
    assignment_spes = spe_updates.map do |update|

      update_responses << { request_uuid: update[:request_uuid], update_status: 'accepted' }

      AssignmentSpe.new(
        uuid: update[:request_uuid],
        assignment_uuid: update[:assignment_uuid],
        exercise_uuids: update[:exercise_uuids]
      )
    end

    AssignmentSpe.import assignment_spes, validate: false, on_duplicate_key_update: {
      conflict_target: [:assignment_uuid],
      columns: [
        :uuid,
        :exercise_uuids
      ]
    }

    { spe_update_responses: update_responses }
  end
end