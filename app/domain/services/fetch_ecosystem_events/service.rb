# This code will not return events with gaps in the sequence_number
class Services::FetchEcosystemEvents::Service < Services::ApplicationService
  MAX_EVENTS = 10

  def process(ecosystem_event_requests:)
    ecosystem_uuids = ecosystem_event_requests.map { |request| request.fetch(:ecosystem_uuid) }

    # The following 2 queries need to be consistent with each other (atomic)
    # We do this by using the result from the first one to limit the returned results
    # from the second, combined with the fact that events are append-only and cannot be modified

    # Find the first and second gaps for each ecosystem (last record also counts as gap)
    sequence_number_before_first_gap_by_ecosystem_uuid = {}
    ecosystem_uuids_with_gaps = Set.new
    EcosystemEvent.before_gap_with_ecosystem_gap_number
                  .where(ecosystem_uuid: ecosystem_uuids, ecosystem_gap_number: [1, 2])
                  .pluck(:ecosystem_uuid, :ecosystem_gap_number, :sequence_number)
                  .each do |ecosystem_uuid, ecosystem_gap_number, sequence_number|
      if ecosystem_gap_number == 1
        sequence_number_before_first_gap_by_ecosystem_uuid[ecosystem_uuid] = sequence_number
      else
        # One gap could just be the end of the sequence, but a second gap indicates a missing value
        ecosystem_uuids_with_gaps << ecosystem_uuid
      end
    end

    # Build the second query while ensuring
    # that we don't get any records inserted since we ran the first one
    num_requests = ecosystem_event_requests.size
    max_events_per_request = MAX_EVENTS/num_requests
    limits_by_request_uuid = {}
    ee = EcosystemEvent.arel_table
    event_query = ecosystem_event_requests.map do |request|
      ecosystem_uuid = request.fetch(:ecosystem_uuid)
      sequence_number_before_first_gap =
        sequence_number_before_first_gap_by_ecosystem_uuid[ecosystem_uuid]
      # Skip if there are no EcosystemEvents for this Ecosystem
      next if sequence_number_before_first_gap.nil?

      sequence_number_offset = request.fetch(:sequence_number_offset)
      request_uuid = request.fetch(:request_uuid)
      limit = [request.fetch(:max_num_events, max_events_per_request), max_events_per_request].min
      limits_by_request_uuid[request_uuid] = limit

      ee.where(
        ee[:ecosystem_uuid].eq(ecosystem_uuid)
          .and(ee[:type].in(request.fetch(:event_types)))
          .and(ee[:sequence_number].gteq(sequence_number_offset))
          .and(ee[:sequence_number].lteq(sequence_number_before_first_gap))
      )
      .order(:sequence_number)
      .project(ee[Arel.star], "'#{request_uuid}' AS request_uuid")
      .take(limit)
    end.compact.reduce { |full_query, new_query| Arel::Nodes::UnionAll.new(full_query, new_query) }

    # http://radar.oreilly.com/2014/05/more-than-enough-arel.html
    from_query = ee.create_table_alias(event_query, :ecosystem_events)
    ecosystem_events_by_request_uuid = event_query.nil? ?
      {} : EcosystemEvent.from(from_query).group_by(&:request_uuid)

    responses = ecosystem_event_requests.map do |request|
      request_uuid = request.fetch(:request_uuid)
      ecosystem_events = ecosystem_events_by_request_uuid[request_uuid] || []

      ecosystem_uuid = request.fetch(:ecosystem_uuid)

      event_hashes = ecosystem_events.map do |event|
        {
          sequence_number: event.sequence_number,
          event_uuid: event.uuid,
          event_type: event.type,
          event_data: event.data
        }
      end

      is_gap = ecosystem_uuids_with_gaps.include? ecosystem_uuid

      is_end = if is_gap
        # There is a gap, so this is definitely not the end of the sequence
        false
      else
        # No gap, so sequence_number_before_first_gap really is the end of the sequence
        # Just have to check that we returned enough results
        sequence_number_offset = request.fetch(:sequence_number_offset)
        sequence_number_before_first_gap =
          sequence_number_before_first_gap_by_ecosystem_uuid[ecosystem_uuid]
        limit = limits_by_request_uuid.fetch(request_uuid)

        limit >= sequence_number_before_first_gap + 1 - sequence_number_offset
      end

      {
        request_uuid: request_uuid,
        ecosystem_uuid: ecosystem_uuid,
        events: event_hashes,
        is_gap: is_gap,
        is_end: is_end
      }
    end

    { ecosystem_event_responses: responses }
  end
end
