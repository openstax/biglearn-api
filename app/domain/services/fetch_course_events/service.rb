# This code will not return events with gaps in the sequence_number
class Services::FetchCourseEvents::Service < Services::ApplicationService
  MAX_EVENTS = 100

  def process(course_event_requests:)
    course_uuids = course_event_requests.map { |request| request.fetch(:course_uuid) }

    # The following 2 queries need to be consistent with each other (atomic)
    # We do this by using the result from the first one to limit the returned results
    # from the second, combined with the fact that events are append-only and cannot be modified

    # Find the first and second gaps for each course (last record also counts as gap)
    sequence_number_before_first_gap_by_course_uuid = {}
    course_uuids_with_gaps = Set.new
    CourseEvent.before_gap_with_course_gap_number
               .where(course_uuid: course_uuids, course_gap_number: [1, 2])
               .pluck(:course_uuid, :course_gap_number, :sequence_number)
               .each do |course_uuid, course_gap_number, sequence_number|
      if course_gap_number == 1
        sequence_number_before_first_gap_by_course_uuid[course_uuid] = sequence_number
      else
        # One gap could just be the end of the sequence, but a second gap indicates a missing value
        course_uuids_with_gaps << course_uuid
      end
    end

    # Build the second query while ensuring
    # that we don't get any records inserted since we ran the first one
    num_requests = course_event_requests.size
    max_events_per_request = MAX_EVENTS/num_requests
    limits_by_request_uuid = {}
    ce = CourseEvent.arel_table
    event_query = course_event_requests.map do |request|
      course_uuid = request.fetch(:course_uuid)
      sequence_number_before_first_gap =
        sequence_number_before_first_gap_by_course_uuid[course_uuid]
      # Skip if there are no CourseEvents for this Course
      next if sequence_number_before_first_gap.nil?

      sequence_number_offset = request.fetch(:sequence_number_offset)
      request_uuid = request.fetch(:request_uuid)
      limit = [request.fetch(:max_num_events, max_events_per_request), max_events_per_request].min
      limits_by_request_uuid[request_uuid] = limit

      ce.where(
        ce[:course_uuid].eq(course_uuid)
          .and(ce[:type].in(request.fetch(:event_types)))
          .and(ce[:sequence_number].gteq(sequence_number_offset))
          .and(ce[:sequence_number].lteq(sequence_number_before_first_gap))
      )
      .order(:sequence_number)
      .project(ce[Arel.star], "'#{request_uuid}' AS request_uuid")
      .take(limit)
    end.compact.reduce { |full_query, new_query| Arel::Nodes::UnionAll.new(full_query, new_query) }

    # http://radar.oreilly.com/2014/05/more-than-enough-arel.html
    from_query = ce.create_table_alias(event_query, :course_events)
    course_events_by_request_uuid = event_query.nil? ?
      {} : CourseEvent.from(from_query).group_by(&:request_uuid)

    responses = course_event_requests.map do |request|
      request_uuid = request.fetch(:request_uuid)
      course_events = course_events_by_request_uuid[request_uuid] || []

      course_uuid = request.fetch(:course_uuid)

      event_hashes = course_events.map do |event|
        {
          sequence_number: event.sequence_number,
          event_uuid: event.uuid,
          event_type: event.type,
          event_data: event.data
        }
      end

      is_gap = course_uuids_with_gaps.include? course_uuid

      is_end = if is_gap
        # There is a gap, so this is definitely not the end of the sequence
        false
      else
        # No gap, so sequence_number_before_first_gap really is the end of the sequence
        # Just have to check that we returned enough results
        sequence_number_offset = request.fetch(:sequence_number_offset)
        sequence_number_before_first_gap =
          sequence_number_before_first_gap_by_course_uuid[course_uuid]
        limit = limits_by_request_uuid.fetch(request_uuid)

        limit >= sequence_number_before_first_gap + 1 - sequence_number_offset
      end

      {
        request_uuid: request_uuid,
        course_uuid: course_uuid,
        events: event_hashes,
        is_gap: is_gap,
        is_end: is_end
      }
    end

    { course_event_responses: responses }
  end
end
