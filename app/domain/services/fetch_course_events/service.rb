# This code will not return events with gaps in the sequence_number
class Services::FetchCourseEvents::Service < Services::ApplicationService
  MAX_DATA_SIZE = 1000000 # For the data field, in characters

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
      INNER JOIN (#{ValuesTable.new(course_event_values_array)})
        AS "requests" ("course_uuid", "sequence_number_offset", "event_types", "request_uuid")
        ON "course_events"."course_uuid" = "requests"."course_uuid"
          AND "course_events"."sequence_number" >= "requests"."sequence_number_offset"
          AND "course_events"."type" = ANY ("requests"."event_types")
    JOIN_SQL

    # Also return gap information about each record
    course_event_sql = CourseEvent.select(
      <<-SQL.strip_heredoc
        "course_events"."sequence_number",
        "course_events"."uuid",
        "course_events"."type",
        "course_events"."data",
        CASE WHEN "course_events"."sequence_number" > 0
          AND NOT EXISTS (
            SELECT "previous_event".*
            FROM "course_events" AS "previous_event"
            WHERE "previous_event"."course_uuid" = "course_events"."course_uuid"
              AND "previous_event"."sequence_number" = "course_events"."sequence_number" - 1
          ) THEN TRUE
        ELSE FALSE
        END AS "is_after_gap",
        "requests"."request_uuid"
      SQL
    )
    .joins(course_event_join_query)
    .order('"requests"."request_uuid" ASC', :sequence_number)
    .limit(max_num_events)
    .to_sql

    # Stream the data from Postgres and stop when the size limit is exceeded
    connection = CourseEvent.connection.raw_connection
    decoder = PG::TextDecoder::CopyRow.new
    data_size = 0
    is_size_limited = false
    num_events = 0
    course_events_by_request_uuid = Hash.new { |hash, key| hash[key] = [] }
    connection.copy_data "COPY (#{course_event_sql}) TO STDOUT", decoder do
      while row = connection.get_copy_data
        if data_size >= MAX_DATA_SIZE
          is_size_limited = true

          next
        end

        num_events += 1
        data_size += row.fourth.size
        course_events_by_request_uuid[row[5]] << row
      end
    end

    is_limited = is_size_limited || num_events >= max_num_events

    responses = course_event_requests.map do |request|
      request_uuid = request.fetch(:request_uuid)

      course_events = course_events_by_request_uuid[request_uuid] || []
      is_gap = false
      event_hashes = course_events.map do |event|
        is_gap = true if event.fifth == 't'

        next if is_gap

        {
          sequence_number: event.first.to_i,
          event_uuid: event.second,
          event_type: CourseEvent.types.key(event.third.to_i),
          event_data: JSON.parse(event.fourth)
        }
      end.compact

      # If we ran into the event limit or detected a gap, this means we are not sending some
      # CourseEvents, so this is not the end of the sequence
      {
        request_uuid: request_uuid,
        course_uuid: request.fetch(:course_uuid),
        events: event_hashes,
        is_gap: is_gap,
        is_end: !is_limited && !is_gap
      }
    end

    { course_event_responses: responses }
  end
end
