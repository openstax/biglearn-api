# This code will not return events with gaps in the sequence_number
# AS LONG AS you don't skip ahead of gaps using the sequence_number_offset
class Services::FetchCourseEvents::Service
  DEFAULT_EVENT_LIMIT_PER_COURSE = 1000

  def process(course_event_requests:)
    ce = CourseEvent.arel_table
    queries = course_event_requests.map do |request|
      limit = request[:event_limit] || DEFAULT_EVENT_LIMIT_PER_COURSE

      ce[:course_uuid]
        .eq(request[:course_uuid])
        .and(ce[:event_type].in(request[:event_types]))
        .and(ce[:sequence_number].gteq(request[:sequence_number_offset]))
        .and(ce[:sequence_number].lt(request[:sequence_number_offset] + limit))
    end.reduce(:or)

    course_events_by_course_uuid = CourseEvent.where(queries)
                                              .order(:sequence_number)
                                              .group_by(&:course_uuid)

    responses = course_event_requests.map do |request|
      course_events = course_events_by_course_uuid[request[:course_uuid]]

      current_sequence_number = request[:sequence_number_offset]
      is_gap = false
      gapless_event_hashes = []
      course_events.each do |event|
        is_gap = event.sequence_number != current_sequence_number
        break if is_gap # Gap detected... Stop processing

        event_hash = {
          sequence_number: event.sequence_number,
          event_uuid: event.uuid,
          event_type: event.type,
          event_data: event.data
        }
        gapless_event_hashes << event_hash

        current_sequence_number += 1
      end

      {
        request_uuid: request[:request_uuid],
        course_uuid: request[:course_uuid],
        events: gapless_event_hashes,
        is_stopped_at_gap: is_gap
      }
    end

    { course_event_responses: responses }
  end
end
