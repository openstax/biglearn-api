class Services::FetchStudentClues::Service < Services::ApplicationService
  def process(student_clue_requests:)
    return { student_clue_responses: [] } if student_clue_requests.empty?

    student_clue_values_array = student_clue_requests.map do |request|
      request.values_at(:student_uuid, :book_container_uuid, :algorithm_name)
    end
    student_clue_join_query = <<-JOIN_SQL.strip_heredoc
      INNER JOIN (#{ValuesTable.new(student_clue_values_array)})
        AS "requests" ("student_uuid", "book_container_uuid", "algorithm_name")
        ON "student_clues"."student_uuid" = "requests"."student_uuid"::uuid
          AND "student_clues"."book_container_uuid" = "requests"."book_container_uuid"::uuid
          AND "student_clues"."algorithm_name" = "requests"."algorithm_name"
    JOIN_SQL

    clues_map = Hash.new { |hash, key| hash[key] = {} }
    StudentClue.transaction do
      StudentClue.joins(student_clue_join_query).each do |clue|
        clues_map[clue.student_uuid.downcase][clue.book_container_uuid.downcase] = clue
      end

      missing_clue_requests = student_clue_requests.reject do |request|
        student_uuid = request.fetch(:student_uuid).downcase
        book_container_uuid = request.fetch(:book_container_uuid).downcase
        clues_map[student_uuid][book_container_uuid]
      end
      missing_clue_student_uuids = missing_clue_requests.map do |request|
        request.fetch(:student_uuid)
      end
      missing_clue_students_by_uuid = Student.where(uuid: missing_clue_student_uuids)
                                             .index_by(&:uuid)
      missing_clue_book_container_uuids = missing_clue_requests.map do |request|
        request.fetch(:book_container_uuid)
      end
      missing_clue_book_containers_by_uuid = \
        BookContainer.where(uuid: missing_clue_book_container_uuids)
                     .index_by{ |bc| bc.uuid.downcase }

      responses = student_clue_requests.map do |request|
        student_uuid = request.fetch(:student_uuid).downcase
        book_container_uuid = request.fetch(:book_container_uuid).downcase
        clue = clues_map[student_uuid][book_container_uuid]

        if clue.nil?
          book_container = missing_clue_book_containers_by_uuid[book_container_uuid]

          calculation_uuid = nil

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
          calculation_uuid = clue.calculation_uuid

          clue_data = clue.data

          clue_status = 'clue_ready'
        end

        {
          request_uuid: request.fetch(:request_uuid),
          calculation_uuid: calculation_uuid,
          clue_data: clue_data,
          clue_status: clue_status
        }
      end

      { student_clue_responses: responses }
    end
  end
end
