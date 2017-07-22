class Services::FetchTeacherClues::Service < Services::ApplicationService
  def process(teacher_clue_requests:)
    tc = TeacherClue.arel_table
    queries = ArelTrees.or_tree(
      teacher_clue_requests.map do |request|
        tc[:course_container_uuid].eq(request.fetch(:course_container_uuid)).and(
          tc[:book_container_uuid].eq(request.fetch(:book_container_uuid)).and(
            tc[:algorithm_name].eq(request.fetch(:algorithm_name))
          )
        )
      end
    )

    clues_map = Hash.new { |hash, key| hash[key] = {} }
    TeacherClue.where(queries).each do |clue|
      clues_map[clue.course_container_uuid.downcase][clue.book_container_uuid.downcase] = clue
    end unless queries.nil?

    missing_clue_requests = teacher_clue_requests.reject do |request|
      course_container_uuid = request.fetch(:course_container_uuid).downcase
      book_container_uuid = request.fetch(:book_container_uuid).downcase
      clues_map[course_container_uuid][book_container_uuid]
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
      course_container_uuid = request.fetch(:course_container_uuid).downcase
      book_container_uuid = request.fetch(:book_container_uuid).downcase
      clue = clues_map[course_container_uuid][book_container_uuid]

      if clue.nil?
        book_container = missing_clue_book_containers_by_uuid[book_container_uuid]

        clue_data = {
          minimum: 0,
          most_likely: 0.5,
          maximum: 1,
          is_real: false
        }

        if book_container.nil?
          clue_status = 'book_container_unknown'
        else
          clue_data.merge!(ecosystem_uuid: book_container.ecosystem_uuid)

          if missing_clue_course_containers_by_uuid[course_container_uuid].nil?
            clue_status = 'course_container_unknown'
          else
            clue_status = 'clue_unready'
          end
        end
      else
        clue_data = clue.data

        clue_status = 'clue_ready'
      end

      { request_uuid: request.fetch(:request_uuid), clue_data: clue_data, clue_status: clue_status }
    end

    { teacher_clue_responses: responses }
  end
end
