class Services::FetchStudentClues::Service < Services::ApplicationService
  def process(student_clue_requests:)
    return { student_clue_responses: [] } if student_clue_requests.empty?

    # Using a join on VALUES is faster than multiple OR queries
    values = student_clue_requests.map do |request|
      "(#{
        [
          "#{StudentClue.sanitize(request.fetch(:student_uuid))}::uuid",
          "#{StudentClue.sanitize(request.fetch(:book_container_uuid))}::uuid",
          StudentClue.sanitize(request.fetch(:algorithm_name))
        ].join(', ')
      })"
    end.join(', ')
    join_query = <<-JOIN_SQL
      INNER JOIN (VALUES #{values})
        AS "requests" ("student_uuid", "book_container_uuid", "algorithm_name")
        ON "student_clues"."student_uuid" = "requests"."student_uuid"
          AND "student_clues"."book_container_uuid" = "requests"."book_container_uuid"
          AND "student_clues"."algorithm_name" = "requests"."algorithm_name"
    JOIN_SQL

    clues_map = Hash.new { |hash, key| hash[key] = {} }
    StudentClue.joins(join_query).each do |clue|
      clues_map[clue.student_uuid.downcase][clue.book_container_uuid.downcase] = clue
    end

    missing_clue_requests = student_clue_requests.reject do |request|
      clues_map[request.fetch(:student_uuid).downcase][request.fetch(:book_container_uuid).downcase]
    end
    missing_clue_student_uuids = missing_clue_requests.map { |request| request.fetch(:student_uuid) }
    missing_clue_students_by_uuid = Student.where(uuid: missing_clue_student_uuids).index_by(&:uuid)
    missing_clue_book_container_uuids = missing_clue_requests.map do |request|
      request.fetch(:book_container_uuid)
    end
    missing_clue_book_containers_by_uuid = \
      BookContainer.where(uuid: missing_clue_book_container_uuids).index_by{ |bc| bc.uuid.downcase }

    responses = student_clue_requests.map do |request|
      student_uuid = request.fetch(:student_uuid).downcase
      book_container_uuid = request.fetch(:book_container_uuid).downcase
      clue = clues_map[student_uuid][book_container_uuid]

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

          if missing_clue_students_by_uuid[student_uuid].nil?
            clue_status = 'student_unknown'
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

    { student_clue_responses: responses }
  end
end
