class Services::FetchAssignmentSpes::Service
  def process(spe_requests:)
    assignment_uuids = spe_requests.map{ |request| request[:assignment_uuid].downcase }
    assignment_spes = AssignmentSpe.where(assignment_uuid: assignment_uuids)
    assignment_spes_by_assignment_uuid = assignment_spes.index_by do |asp|
      asp.assignment_uuid.downcase
    end

    missing_spe_assignment_uuids = assignment_uuids - assignment_spes_by_assignment_uuid.keys
    missing_spe_assignments = Assignment.where(assignment_uuid: missing_spe_assignment_uuids)
    missing_spe_assignments_by_uuid = missing_spe_assignments.index_by do |mspa|
      mspa.assignment_uuid.downcase
    end

    spe_responses = spe_requests.map do |request|
      assignment_uuid = request[:assignment_uuid]
      assignment_spe = assignment_spes_by_assignment_uuid[assignment_uuid]

      if assignment_spe.nil?
        exercise_uuids = []

        assignment = missing_spe_assignments_by_uuid[assignment_uuid]
        assignment_status = assignment.nil? ? 'assignment_unknown' : 'assignment_unready'
      else
        exercise_uuids = assignment_spe.exercise_uuids.uniq.first(request[:max_num_exercises])

        assignment_status = 'assignment_ready'
      end

      {
        assignment_uuid: assignment_uuid,
        exercise_uuids: exercise_uuids,
        assignment_status: assignment_status
      }
    end

    { spe_responses: spe_responses }
  end
end
