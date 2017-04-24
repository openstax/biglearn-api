# This code will not return events with gaps in the sequence_number
class Services::FetchCourseEvents::Service
  MAX_EVENTS = 100

  def process(course_event_requests:)
    num_requests = course_event_requests.size
    max_events_per_request = MAX_EVENTS/num_requests

    limits_by_request_uuid = {}
    ce = CourseEvent.arel_table
    event_query = course_event_requests.map do |request|
      sequence_number_offset = request.fetch(:sequence_number_offset)
      request_uuid = request.fetch(:request_uuid)
      limit = [request.fetch(:max_num_events, max_events_per_request), max_events_per_request].min
      limits_by_request_uuid[request_uuid] = limit

      ce.where(
        ce[:course_uuid].eq(request.fetch(:course_uuid))
          .and(ce[:type].in(request.fetch(:event_types)))
          .and(ce[:sequence_number].gteq(sequence_number_offset))
      )
      .order(:sequence_number)
      .project(ce[Arel.star], "'#{request_uuid}' AS request_uuid")
      .take(limit + 1)
    end.reduce { |full_query, new_query| Arel::Nodes::UnionAll.new(full_query, new_query) }

    course_uuids = course_event_requests.map { |request| request.fetch(:course_uuid) }

    # The following 2 queries need to be consistent with each other, so we use a transaction
    course_events_by_request_uuid = {}
    end_of_first_gap_by_course_uuid = CourseEvent.transaction do
      # http://radar.oreilly.com/2014/05/more-than-enough-arel.html
      course_events_by_request_uuid =
        CourseEvent.from(ce.create_table_alias(event_query, :course_events))
                   .group_by(&:request_uuid) \
          unless event_query.nil?

      # Find the first gap in each course
      CourseEvent
        .after_gap_with_course_gap_number
        .where(course_uuid: course_uuids, course_gap_number: 1)
        .pluck(:course_uuid, :sequence_number)
        .to_h
    end

    responses = course_event_requests.map do |request|
      request_uuid = request.fetch(:request_uuid)
      course_events = course_events_by_request_uuid[request_uuid] || []
      included_event_types = Set.new(request.fetch(:event_types))

      limit = limits_by_request_uuid.fetch(request_uuid)

      course_uuid = request.fetch(:course_uuid)
      end_of_first_gap = end_of_first_gap_by_course_uuid[course_uuid]
      gapless_course_events, gap_course_events = course_events.partition do |course_event|
        # This condition assumes rows in the gap do not exist in both queries
        # Should work as long as both queries happen in a transaction
        end_of_first_gap.nil? || course_event.sequence_number < end_of_first_gap
      end

      gapless_event_hashes = gapless_course_events.first(limit).map do |event|
        {
          sequence_number: event.sequence_number,
          event_uuid: event.uuid,
          event_type: event.type,
          event_data: event.data
        }
      end

      is_gap = !gap_course_events.empty?

      {
        request_uuid: request_uuid,
        course_uuid: request.fetch(:course_uuid),
        events: gapless_event_hashes,
        is_gap: is_gap,
        is_end: !is_gap && gapless_course_events[limit + 1].nil?
      }
    end

    { course_event_responses: responses }
  end
end
