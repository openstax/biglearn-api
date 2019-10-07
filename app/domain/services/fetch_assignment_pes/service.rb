class Services::FetchAssignmentPes::Service < Services::ApplicationService
  def process(pe_requests:)
    return { pe_responses: [] } if pe_requests.empty?

    pe_values_array = pe_requests.map do |request|
      request.values_at(:assignment_uuid, :algorithm_name)
    end
    pe_join_query = <<-JOIN_SQL.strip_heredoc
      INNER JOIN (#{ValuesTable.new(pe_values_array)})
        AS "requests" ("assignment_uuid", "algorithm_name")
        ON "assignment_pes"."assignment_uuid" = "requests"."assignment_uuid"::uuid
          AND "assignment_pes"."algorithm_name" = "requests"."algorithm_name"
    JOIN_SQL

    Assignment.transaction do
      assignment_pes_by_assignment_uuid = AssignmentPe.joins(pe_join_query).index_by do |ap|
        ap.assignment_uuid.downcase
      end

      assignment_uuids = pe_requests.map { |request| request.fetch(:assignment_uuid).downcase }
      missing_pe_assignment_uuids = assignment_uuids - assignment_pes_by_assignment_uuid.keys
      missing_pe_assignments = Assignment.where(uuid: missing_pe_assignment_uuids)
      missing_pe_assignments_by_uuid = missing_pe_assignments.index_by { |mpa| mpa.uuid.downcase }

      pe_responses = pe_requests.map do |request|
        request_uuid = request.fetch(:request_uuid)
        assignment_uuid = request.fetch(:assignment_uuid)
        assignment_pe = assignment_pes_by_assignment_uuid[assignment_uuid]

        if assignment_pe.nil?
          calculation_uuid = nil
          ecosystem_matrix_uuid = nil
          exercise_uuids = []
          assignment = missing_pe_assignments_by_uuid[assignment_uuid]
          assignment_status = assignment.nil? ? 'assignment_unknown' : 'assignment_unready'
          spy_info = {}
        else
          calculation_uuid = assignment_pe.calculation_uuid
          ecosystem_matrix_uuid = assignment_pe.ecosystem_matrix_uuid
          all_exercise_uuids = assignment_pe.exercise_uuids.uniq
          max_num_exercises = request[:max_num_exercises]
          exercise_uuids = max_num_exercises.nil? ?
                             all_exercise_uuids : all_exercise_uuids.first(max_num_exercises)
          assignment_status = 'assignment_ready'
          spy_info = assignment_pe.spy_info
        end

        {
          request_uuid: request_uuid,
          calculation_uuid: calculation_uuid,
          ecosystem_matrix_uuid: ecosystem_matrix_uuid,
          assignment_uuid: assignment_uuid,
          exercise_uuids: exercise_uuids,
          assignment_status: assignment_status,
          spy_info: spy_info
        }
      end

      { pe_responses: pe_responses }
    end
  end
end
