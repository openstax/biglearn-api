class Services::FetchStudentClues::Service
  def process(student_clue_requests:)
    sc = StudentClue.arel_table
    queries = student_clue_requests.map do |request|
      sc[:student_uuid].eq(request[:student_uuid]).and(
        sc[:book_container_uuid].eq(request[:book_container_uuid])
      )
    end.reduce(:or)
    clues = queries.nil? ? StudentClue.none : StudentClue.where(queries)

    clues_map = Hash.new { |hash, key| hash[key] = {} }
    clues.each do |clue|
      clues_map[clue.student_uuid.downcase][clue.book_container_uuid.downcase] = clue
    end

    missing_clue_requests = student_clue_requests.reject do |request|
      clues_map[request[:student_uuid].downcase][request[:book_container_uuid].downcase]
    end
    missing_clue_student_uuids = missing_clue_requests.map { |request| request[:student_uuid] }
    missing_clue_students_by_uuid = Student.where(uuid: missing_clue_student_uuids).index_by(&:uuid)
    missing_clue_book_container_uuids = missing_clue_requests.map do |request|
      request[:book_container_uuid]
    end
    missing_clue_book_containers_by_uuid = \
      BookContainer.where(uuid: missing_clue_book_container_uuids).index_by(&:uuid)

    responses = student_clue_requests.map do |request|
      clue = clues_map[request[:student_uuid].downcase][request[:book_container_uuid].downcase]

      if clue.nil?
        clue_data = {
          aggregate: 0.5,
          confidence: {
            left: 0,
            right: 1,
            sample_size: 0,
            unique_learner_count: 0
          },
          interpretation: {
            confidence: 'bad',
            level: 'low',
            threshold: 'below'
          },
          pool_id: request[:book_container_uuid]
        }

        clue_status = if missing_clue_book_containers_by_uuid[request[:book_container_uuid]].nil?
          'book_container_unknown'
        elsif missing_clue_students_by_uuid[request[:student_uuid]].nil?
          'student_unknown'
        else
          'clue_unready'
        end
      else
        clue_data = {
          aggregate: clue.aggregate,
          confidence: {
            left: clue.confidence_left,
            right: clue.confidence_right,
            sample_size: clue.sample_size,
            unique_learner_count: clue.unique_learner_count
          },
          interpretation: {
            confidence: clue.is_good_confidence ? 'good' : 'bad',
            level: clue.is_high_level ? 'high' : 'low',
            threshold: clue.is_above_threshold ? 'above' : 'below'
          },
          pool_id: request[:book_container_uuid]
        }

        clue_status = 'clue_ready'
      end

      { request_uuid: request[:request_uuid], clue_data: clue_data, clue_status: clue_status }
    end

    { student_clue_responses: responses }
  end
end
