class Services::FetchAssignmentSpes::Service < Services::ApplicationService
  def process(spe_requests:)
    return { spe_responses: [] } if spe_requests.empty?

    # Using a join on VALUES is faster than multiple OR queries
    values = spe_requests.map do |request|
      "(#{
        [
          "#{AssignmentSpe.sanitize(request.fetch(:assignment_uuid))}::uuid",
          AssignmentSpe.sanitize(request.fetch(:algorithm_name))
        ].join(', ')
      })"
    end.join(', ')
    join_query = <<-JOIN_SQL
      INNER JOIN (VALUES #{values}) AS "requests" ("assignment_uuid", "algorithm_name")
        ON "assignment_spes"."assignment_uuid" = "requests"."assignment_uuid"
          AND "assignment_spes"."algorithm_name" = "requests"."algorithm_name"
    JOIN_SQL

    assignment_spes_by_assignment_uuid = AssignmentSpe.joins(join_query).index_by do |ap|
      ap.assignment_uuid.downcase
    end

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
        spy_info = {}
      else
        all_exercise_uuids = assignment_spe.exercise_uuids.uniq
        max_num_exercises = request[:max_num_exercises]
        exercise_uuids = max_num_exercises.nil? ?
                           all_exercise_uuids : all_exercise_uuids.first(max_num_exercises)
        assignment_status = 'assignment_ready'
        spy_info = assignment_spe.spy_info
      end

      {
        request_uuid: request_uuid,
        assignment_uuid: assignment_uuid,
        exercise_uuids: exercise_uuids,
        assignment_status: assignment_status,
        spy_info: spy_info
      }
    end

    { spe_responses: spe_responses }
  end
end
