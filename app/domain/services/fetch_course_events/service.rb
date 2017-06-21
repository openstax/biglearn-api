# This code will not return events with gaps in the sequence_number
class Services::FetchCourseEvents::Service < Services::ApplicationService
  MAX_EVENTS = 100

  def process(course_event_requests:)
    # Build a single query that returns the requested events using UNION ALL
    num_requests = course_event_requests.size
    max_events_per_request = MAX_EVENTS/num_requests
    limits_by_request_uuid = {}
    ce = CourseEvent.arel_table
    event_query = course_event_requests.map do |request|
      course_uuid = request.fetch(:course_uuid)
      sequence_number_offset = request.fetch(:sequence_number_offset)
      request_uuid = request.fetch(:request_uuid)
      limit = [request.fetch(:max_num_events, max_events_per_request), max_events_per_request].min
      limits_by_request_uuid[request_uuid] = limit

      ce.where(
        ce[:course_uuid].eq(course_uuid)
          .and(ce[:type].in(request.fetch(:event_types)))
          .and(ce[:sequence_number].gteq(sequence_number_offset))
      )
      .order(:sequence_number)
      .project(ce[Arel.star], "'#{request_uuid}' AS \"request_uuid\"")
      .take(limit)
    end.reduce { |full_query, new_query| Arel::Nodes::UnionAll.new(full_query, new_query) }

    # http://radar.oreilly.com/2014/05/more-than-enough-arel.html
    from_query = ce.create_table_alias(event_query, :course_events)

    # Also return gap information with each record
    course_events_by_request_uuid = event_query.nil? ?
      {} :
      CourseEvent.from(from_query).select(
        <<-SQL.strip_heredoc
          "course_events".*, CASE WHEN "course_events"."sequence_number" > 0
            AND NOT EXISTS (
              SELECT "previous_event".*
              FROM "course_events" AS "previous_event"
              WHERE "previous_event"."course_uuid" = "course_events"."course_uuid"
                AND "previous_event"."sequence_number" = "course_events"."sequence_number" - 1
            ) THEN TRUE
          ELSE FALSE
          END AS "is_after_gap"
        SQL
      ).group_by(&:request_uuid)

    responses = course_event_requests.map do |request|
      request_uuid = request.fetch(:request_uuid)

      course_events = course_events_by_request_uuid[request_uuid] || []
      is_gap = false
      event_hashes = course_events.map do |event|
        is_gap = true if event.is_after_gap

        next if is_gap

        {
          sequence_number: event.sequence_number,
          event_uuid: event.uuid,
          event_type: event.type,
          event_data: event.data
        }
      end.compact

      # If we detected a gap, this means we are not sending some CourseEvents,
      # so this is not the end of the sequence
      # If we didn't detect a gap, then we check if we returned
      # less than the number of CourseEvents requested
      is_end = !is_gap && limits_by_request_uuid.fetch(request_uuid) > course_events.size

      {
        request_uuid: request_uuid,
        course_uuid: request.fetch(:course_uuid),
        events: event_hashes,
        is_gap: is_gap,
        is_end: is_end
      }
    end

    { course_event_responses: responses }
  end
end
