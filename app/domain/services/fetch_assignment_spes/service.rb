class Services::FetchAssignmentSpes::Service
  def process(spe_requests:)
    aspe = AssignmentSpe.arel_table
    queries = spe_requests.map do |request|
      aspe[:assignment_uuid].eq(request.fetch(:assignment_uuid)).and(
        aspe[:algorithm_name].eq(request.fetch(:algorithm_name))
      )
    end.reduce(:or)
    assignment_spes_by_assignment_uuid = queries.nil? ?
      {} : AssignmentSpe.where(queries).index_by { |as| as.assignment_uuid.downcase }

    assignment_uuids = spe_requests.map { |request| request.fetch(:assignment_uuid).downcase }
    missing_spe_assignment_uuids = assignment_uuids - assignment_spes_by_assignment_uuid.keys
    missing_spe_assignments = Assignment.where(uuid: missing_spe_assignment_uuids)
    missing_spe_assignments_by_uuid = missing_spe_assignments.index_by { |mspa| mspa.uuid.downcase }

    spe_responses = spe_requests.map do |request|
      request_uuid = request.fetch(:request_uuid)
      assignment_uuid = request.fetch(:assignment_uuid)
      assignment_spe = assignment_spes_by_assignment_uuid[assignment_uuid]

      if assignment_spe.nil?
        exercise_uuids = []

        assignment = missing_spe_assignments_by_uuid[assignment_uuid]
        assignment_status = assignment.nil? ? 'assignment_unknown' : 'assignment_unready'
      else
        all_exercise_uuids = assignment_spe.exercise_uuids.uniq
        max_num_exercises = request[:max_num_exercises]
        exercise_uuids = max_num_exercises.nil? ?
                           all_exercise_uuids : all_exercise_uuids.first(max_num_exercises)

        assignment_status = 'assignment_ready'
      end

      {
        request_uuid: request_uuid,
        assignment_uuid: assignment_uuid,
        exercise_uuids: exercise_uuids,
        assignment_status: assignment_status
      }
    end

    { spe_responses: spe_responses }
  end
end
