class Services::FetchPracticeWorstAreasExercises::Service
  def process(worst_areas_requests:)
    student_uuids = worst_areas_requests.map{ |request| request.fetch(:student_uuid).downcase }
    student_pes = StudentPe.where(student_uuid: student_uuids)
    student_pes_by_student_uuid = student_pes.index_by{ |sp| sp.student_uuid.downcase }

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
      else
        exercise_uuids = student_pe.exercise_uuids.uniq.first(request.fetch(:max_num_exercises))

        student_status = 'student_ready'
      end

      {
        request_uuid: request_uuid,
        student_uuid: student_uuid,
        exercise_uuids: exercise_uuids,
        student_status: student_status
      }
    end

    { worst_areas_responses: worst_areas_responses }
  end
end
