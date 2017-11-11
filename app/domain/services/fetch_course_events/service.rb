# This code will not return events with gaps in the sequence_number
class Services::FetchCourseEvents::Service < Services::ApplicationService
  MAX_DATA_SIZE = 3.2e7 # For the data field, in bits

  def process(course_event_requests:, max_num_events:)
    return { course_event_responses: [] } if course_event_requests.empty?

    course_event_values_array = course_event_requests.map do |request|
      [
        request.fetch(:course_uuid),
        request.fetch(:sequence_number_offset),
        CourseEvent.types.values_at(*request.fetch(:event_types)),
        request.fetch(:request_uuid)
      ]
    end
    course_event_join_query = <<-JOIN_SQL
      RIGHT OUTER JOIN (#{ValuesTable.new(course_event_values_array)})
        AS "requests" ("course_uuid", "sequence_number_offset", "event_types", "request_uuid")
        ON "course_events"."course_uuid" = "requests"."course_uuid"
          AND "course_events"."sequence_number" >= "requests"."sequence_number_offset"
          AND "course_events"."type" = ANY ("requests"."event_types")
      WINDOW "window" AS (
        ORDER BY "course_events"."sequence_number" - "requests"."sequence_number_offset"
          ASC NULLS FIRST
        ROWS UNBOUNDED PRECEDING
      )
    JOIN_SQL

    # Also return gap information about each record
    course_events = CourseEvent
      .from("(#{
        CourseEvent.select(
          <<-SELECT_SQL.strip_heredoc
            "course_events"."sequence_number",
            "course_events"."uuid",
            "course_events"."type",
            "course_events"."data",
            ROW_NUMBER() OVER "window" AS "row_number",
            SUM(BIT_LENGTH("course_events"."data"::text)) OVER "window" AS "cumulative_size",
            CASE WHEN "course_events"."sequence_number" > 0
              AND NOT EXISTS (
                SELECT "previous_event".*
                FROM "course_events" AS "previous_event"
                WHERE "previous_event"."course_uuid" = "course_events"."course_uuid"
                  AND "previous_event"."sequence_number" = "course_events"."sequence_number" - 1
              ) THEN TRUE
            ELSE FALSE
            END AS "is_after_gap",
            CASE WHEN NOT EXISTS (
              SELECT "next_events".*
              FROM "course_events" AS "next_events"
              WHERE "next_events"."course_uuid" = "course_events"."course_uuid"
                AND "next_events"."sequence_number" > "course_events"."sequence_number"
                AND "next_events"."type" = ANY ("requests"."event_types")
            ) THEN TRUE
            ELSE FALSE
            END AS "is_end",
            "requests"."request_uuid"
          SELECT_SQL
        )
        .joins(course_event_join_query)
        .order(
          '"course_events"."sequence_number" - "requests"."sequence_number_offset" ASC NULLS FIRST'
        )
        .limit(max_num_events)
        .to_sql
      }) AS \"course_events\"")
      .where(
        <<-WHERE_SQL.strip_heredoc
          "row_number" = 1 OR "cumulative_size" IS NULL OR "cumulative_size" < #{MAX_DATA_SIZE.to_i}
        WHERE_SQL
      )
    course_events_by_request_uuid = course_events.group_by(&:request_uuid)

    responses = course_event_requests.map do |request|
      request_uuid = request.fetch(:request_uuid)
      course_uuid = request.fetch(:course_uuid)

      # Limit reached before the first row for this request could be processed
      next {
        request_uuid: request_uuid,
        course_uuid: course_uuid,
        events: [],
        is_gap: false,
        is_end: false
      } if !course_events_by_request_uuid.has_key?(request_uuid)

      is_gap = false
      course_events = course_events_by_request_uuid[request_uuid]
      event_hashes = course_events.map do |course_event|
        is_gap = true if course_event.is_after_gap
        next if is_gap

        uuid = course_event.uuid
        next if uuid.nil?

        {
          sequence_number: course_event.sequence_number,
          event_uuid: uuid,
          event_type: course_event.type,
          event_data: course_event.data
        }
      end.compact

      {
        request_uuid: request_uuid,
        course_uuid: course_uuid,
        events: event_hashes,
        is_gap: is_gap,
        is_end: !is_gap && course_events.last.is_end
      }
    end

    { course_event_responses: responses }
  end
end
