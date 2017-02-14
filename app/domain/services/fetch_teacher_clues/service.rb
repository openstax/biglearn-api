class Services::FetchTeacherClues::Service
  def process(teacher_clue_requests:)
    tc = TeacherClue.arel_table
    queries = teacher_clue_requests.map do |request|
      tc[:course_container_uuid].eq(request.fetch(:course_container_uuid)).and(
        tc[:book_container_uuid].eq(request.fetch(:book_container_uuid))
      )
    end.reduce(:or)
    clues = queries.nil? ? TeacherClue.none : TeacherClue.where(queries)

    clues_map = Hash.new { |hash, key| hash[key] = {} }
    clues.each do |clue|
      clues_map[clue.course_container_uuid.downcase][clue.book_container_uuid.downcase] = clue
    end

    missing_clue_requests = teacher_clue_requests.reject do |request|
      clues_map[request.fetch(:course_container_uuid).downcase][request.fetch(:book_container_uuid).downcase]
    end
    missing_clue_course_container_uuids = missing_clue_requests.map do |request|
      request.fetch(:course_container_uuid)
    end
    missing_clue_course_containers_by_uuid = \
      CourseContainer.where(uuid: missing_clue_course_container_uuids).index_by(&:uuid)
    missing_clue_book_container_uuids = missing_clue_requests.map do |request|
      request.fetch(:book_container_uuid)
    end
    missing_clue_book_containers_by_uuid = \
      BookContainer.where(uuid: missing_clue_book_container_uuids).index_by(&:uuid)

    responses = teacher_clue_requests.map do |request|
      clue = \
        clues_map[request.fetch(:course_container_uuid).downcase][request.fetch(:book_container_uuid).downcase]

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
          pool_id: request.fetch(:book_container_uuid)
        }

        clue_status = if missing_clue_book_containers_by_uuid[request.fetch(:book_container_uuid)].nil?
          'book_container_unknown'
        elsif missing_clue_course_containers_by_uuid[request.fetch(:course_container_uuid)].nil?
          'course_container_unknown'
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
          pool_id: request.fetch(:book_container_uuid)
        }

        clue_status = 'clue_ready'
      end

      { request_uuid: request.fetch(:request_uuid), clue_data: clue_data, clue_status: clue_status }
    end

    { teacher_clue_responses: responses }
  end
end
