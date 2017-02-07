class Services::FetchAssignmentPes::Service
  def process(pe_requests:)
    assignment_uuids = pe_requests.map { |request| request.fetch(:assignment_uuid).downcase }
    assignment_pes = AssignmentPe.where(assignment_uuid: assignment_uuids)
    assignment_pes_by_assignment_uuid = assignment_pes.index_by { |ap| ap.assignment_uuid.downcase }

    missing_pe_assignment_uuids = assignment_uuids - assignment_pes_by_assignment_uuid.keys
    missing_pe_assignments = Assignment.where(uuid: missing_pe_assignment_uuids)
    missing_pe_assignments_by_uuid = missing_pe_assignments.index_by { |mpa| mpa.uuid.downcase }

    pe_responses = pe_requests.map do |request|
      assignment_uuid = request.fetch(:assignment_uuid)
      assignment_pe = assignment_pes_by_assignment_uuid[assignment_uuid]

      if assignment_pe.nil?
        exercise_uuids = []

        assignment = missing_pe_assignments_by_uuid[assignment_uuid]
        assignment_status = assignment.nil? ? 'assignment_unknown' : 'assignment_unready'
      else
        exercise_uuids = assignment_pe.exercise_uuids.uniq.first(request.fetch(:max_num_exercises))

        assignment_status = 'assignment_ready'
      end

      {
        assignment_uuid: assignment_uuid,
        exercise_uuids: exercise_uuids,
        assignment_status: assignment_status
      }
    end

    { pe_responses: pe_responses }
  end
end
