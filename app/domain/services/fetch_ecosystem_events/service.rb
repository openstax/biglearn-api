# This code will not return events with gaps in the sequence_number
class Services::FetchEcosystemEvents::Service
  MAX_EVENTS = 10

  def process(ecosystem_event_requests:)
    num_requests = ecosystem_event_requests.size
    max_events_per_request = MAX_EVENTS/num_requests

    limits_by_request_uuid = {}
    ee = EcosystemEvent.arel_table
    event_query = ecosystem_event_requests.map do |request|
      sequence_number_offset = request.fetch(:sequence_number_offset)
      request_uuid = request.fetch(:request_uuid)
      limit = [request.fetch(:max_num_events, max_events_per_request), max_events_per_request].min
      limits_by_request_uuid[request_uuid] = limit

      ee.where(
        ee[:ecosystem_uuid].eq(request.fetch(:ecosystem_uuid))
          .and(ee[:type].in(request.fetch(:event_types)))
          .and(ee[:sequence_number].gteq(sequence_number_offset))
      )
      .order(:sequence_number)
      .project(ee[Arel.star], "'#{request_uuid}' AS request_uuid")
      .take(limit + 1)
    end.reduce { |full_query, new_query| Arel::Nodes::UnionAll.new(full_query, new_query) }

    ecosystem_uuids = ecosystem_event_requests.map { |request| request.fetch(:ecosystem_uuid) }

    # The following 2 queries need to be consistent with each other, so we use a transaction
    ecosystem_events_by_request_uuid = {}
    end_of_first_gap_by_ecosystem_uuid = EcosystemEvent.transaction do
      # http://radar.oreilly.com/2014/05/more-than-enough-arel.html
      ecosystem_events_by_request_uuid =
        EcosystemEvent.from(ee.create_table_alias(event_query, :ecosystem_events))
                   .group_by(&:request_uuid) \
          unless event_query.nil?

      # Find the first gap in each ecosystem
      EcosystemEvent
        .after_gap_with_ecosystem_gap_number
        .where(ecosystem_uuid: ecosystem_uuids, ecosystem_gap_number: 1)
        .pluck(:ecosystem_uuid, :sequence_number)
        .to_h
    end

    responses = ecosystem_event_requests.map do |request|
      request_uuid = request.fetch(:request_uuid)
      ecosystem_events = ecosystem_events_by_request_uuid[request_uuid] || []
      included_event_types = Set.new(request.fetch(:event_types))

      limit = limits_by_request_uuid.fetch(request_uuid)

      ecosystem_uuid = request.fetch(:ecosystem_uuid)
      end_of_first_gap = end_of_first_gap_by_ecosystem_uuid[ecosystem_uuid]
      gapless_eco_events, gap_eco_events = ecosystem_events.partition do |ecosystem_event|
        # This condition assumes rows in the gap do not exist in both queries
        # Should work as long as both queries happen in a transaction
        end_of_first_gap.nil? || ecosystem_event.sequence_number < end_of_first_gap
      end

      gapless_event_hashes = gapless_eco_events.first(limit).map do |event|
        {
          sequence_number: event.sequence_number,
          event_uuid: event.uuid,
          event_type: event.type,
          event_data: event.data
        }
      end

      is_gap = !gap_eco_events.empty?

      {
        request_uuid: request_uuid,
        ecosystem_uuid: request.fetch(:ecosystem_uuid),
        events: gapless_event_hashes,
        is_gap: is_gap,
        is_end: !is_gap && gapless_eco_events[limit + 1].nil?
      }
    end

    { ecosystem_event_responses: responses }
  end
end
