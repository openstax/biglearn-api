class Services::FetchTeacherClues::Service < Services::ApplicationService
  def process(teacher_clue_requests:)
    return { teacher_clue_responses: [] } if teacher_clue_requests.empty?

    # Using a join on VALUES is faster than multiple OR queries
    values = teacher_clue_requests.map do |request|
      "(#{
        [
          "#{TeacherClue.sanitize(request.fetch(:course_container_uuid))}::uuid",
          "#{TeacherClue.sanitize(request.fetch(:book_container_uuid))}::uuid",
          TeacherClue.sanitize(request.fetch(:algorithm_name))
        ].join(', ')
      })"
    end.join(', ')
    join_query = <<-JOIN_SQL
      INNER JOIN (VALUES #{values})
        AS "requests" ("course_container_uuid", "book_container_uuid", "algorithm_name")
        ON "teacher_clues"."course_container_uuid" = "requests"."course_container_uuid"
          AND "teacher_clues"."book_container_uuid" = "requests"."book_container_uuid"
          AND "teacher_clues"."algorithm_name" = "requests"."algorithm_name"
    JOIN_SQL

    clues_map = Hash.new { |hash, key| hash[key] = {} }
    TeacherClue.joins(join_query).each do |clue|
      clues_map[clue.course_container_uuid.downcase][clue.book_container_uuid.downcase] = clue
    end

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
