class Services::FetchPracticeWorstAreasExercises::Service < Services::ApplicationService
  def process(worst_areas_requests:)
    spe = StudentPe.arel_table
    queries = ArelTrees.or_tree(
      worst_areas_requests.map do |request|
        spe[:student_uuid].eq(request.fetch(:student_uuid)).and(
          spe[:algorithm_name].eq(request.fetch(:algorithm_name))
        )
      end
    )

    student_pes_by_student_uuid = queries.nil? ?
      {} : StudentPe.where(queries).index_by { |sp| sp.student_uuid.downcase }

    student_uuids = worst_areas_requests.map { |request| request.fetch(:student_uuid).downcase }
    missing_pe_student_uuids = student_uuids - student_pes_by_student_uuid.keys
    missing_pe_students = Student.where(uuid: missing_pe_student_uuids)
    missing_pe_students_by_uuid = missing_pe_students.index_by { |mps| mps.uuid.downcase }

    worst_areas_responses = worst_areas_requests.map do |request|
      request_uuid = request.fetch(:request_uuid)
      student_uuid = request.fetch(:student_uuid)
      student_pe = student_pes_by_student_uuid[student_uuid]

      if student_pe.nil?
        exercise_uuids = []
        student = missing_pe_students_by_uuid[student_uuid]
        student_status = student.nil? ? 'student_unknown' : 'student_unready'
        spy_info = {}
      else
        all_exercise_uuids = student_pe.exercise_uuids.uniq
        max_num_exercises = request[:max_num_exercises]
        exercise_uuids = max_num_exercises.nil? ?
                           all_exercise_uuids : all_exercise_uuids.first(max_num_exercises)
        student_status = 'student_ready'
        spy_info = student_pe.spy_info
      end

      {
        request_uuid: request_uuid,
        student_uuid: student_uuid,
        exercise_uuids: exercise_uuids,
        student_status: student_status,
        spy_info: spy_info
      }
    end

    { worst_areas_responses: worst_areas_responses }
  end
end
