# This code will not return events with gaps in the sequence_number
class Services::FetchCourseEvents::Service < Services::ApplicationService
  EVENT_LIMIT = 10000     # Sent to Postgres as the LIMIT clause
  MAX_DATA_SIZE = 1000000 # For the data field, in characters

  def process(course_event_requests:)
    # Return the request_uuid that caused each record to be returned
    request_uuid_cases = course_event_requests.map do |request|
      <<-CASE_SQL.strip_heredoc
        WHEN "course_uuid" = #{CourseEvent.sanitize(request.fetch(:course_uuid))}
          AND "sequence_number" >= #{CourseEvent.sanitize(request.fetch(:sequence_number_offset))}
        THEN #{CourseEvent.sanitize(request.fetch(:request_uuid))}
      CASE_SQL
    end.join(' ')

    ce = CourseEvent.arel_table
    # Build a single query that returns the requested events using OR
    event_query = ArelTrees.or_tree(
      course_event_requests.map do |request|
        ce[:course_uuid].eq(request.fetch(:course_uuid))
          .and(ce[:sequence_number].gteq(request.fetch(:sequence_number_offset)))
          .and(ce[:type].in(request.fetch(:event_types)))
      end
    )

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
        CASE #{request_uuid_cases} END AS "request_uuid"
      SQL
    )
    .where(event_query)
    .order(:course_uuid, :sequence_number)
    .limit(EVENT_LIMIT)
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

    is_end = !is_size_limited && num_events < EVENT_LIMIT

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

      # If we detected a gap, this means we are not sending some CourseEvents,
      # so this is not the end of the sequence
      # If we didn't detect a gap, then we check if we returned
      # less than the number of CourseEvents requested
      {
        request_uuid: request_uuid,
        course_uuid: request.fetch(:course_uuid),
        events: event_hashes,
        is_gap: is_gap,
        is_end: is_end && !is_gap
      }
    end

    { course_event_responses: responses }
  end
end
