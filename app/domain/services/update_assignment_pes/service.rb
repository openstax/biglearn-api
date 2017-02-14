class Services::UpdateAssignmentPes::Service
  def process(pe_updates:)
    update_responses = []
    assignment_pes = pe_updates.map do |update|

      update_responses << { request_uuid: update[:request_uuid], update_status: 'accepted' }

      AssignmentPe.new(
        uuid: update[:request_uuid],
        assignment_uuid: update[:assignment_uuid],
        exercise_uuids: update[:exercise_uuids]
      )
    end

    AssignmentPe.import assignment_pes, validate: false, on_duplicate_key_update: {
      conflict_target: [:assignment_uuid],
      columns: [
        :uuid,
        :exercise_uuids
      ]
    }

    { pe_update_responses: update_responses }
  end
end