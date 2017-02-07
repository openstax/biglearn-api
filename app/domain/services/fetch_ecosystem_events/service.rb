# This code will not return events with gaps in the sequence_number
# AS LONG AS you don't skip ahead of gaps using the sequence_number_offset
class Services::FetchEcosystemEvents::Service
  DEFAULT_EVENT_LIMIT_PER_ECOSYSTEM = 1000

  def process(ecosystem_event_requests:)
    ee = EcosystemEvent.arel_table
    queries = ecosystem_event_requests.map do |request|
      limit = request.fetch(:event_limit) || DEFAULT_EVENT_LIMIT_PER_ECOSYSTEM

      ee[:ecosystem_uuid]
        .eq(request.fetch(:ecosystem_uuid))
        .and(ee[:sequence_number].gteq(request.fetch(:sequence_number_offset)))
        .and(ee[:sequence_number].lt(request.fetch(:sequence_number_offset) + limit))
    end.reduce(:or)

    ecosystem_events_by_ecosystem_uuid = EcosystemEvent.where(queries)
                                                       .order(:sequence_number)
                                                       .group_by(&:ecosystem_uuid)

    responses = ecosystem_event_requests.map do |request|
      ecosystem_events = ecosystem_events_by_ecosystem_uuid[request.fetch(:ecosystem_uuid)]
      included_event_types = Set.new(request.fetch(:event_types))

      current_sequence_number = request.fetch(:sequence_number_offset)
      is_gap = false
      gapless_event_hashes = []
      ecosystem_events.each do |event|
        is_gap = event.sequence_number != current_sequence_number
        break if is_gap # Gap detected... Stop processing

        current_sequence_number += 1

        next unless included_event_types.include? event.type # Skip non-included event types

        event_hash = {
          sequence_number: event.sequence_number,
          event_uuid: event.uuid,
          event_type: event.type,
          event_data: event.data
        }
        gapless_event_hashes << event_hash
      end

      {
        request_uuid: request.fetch(:request_uuid),
        ecosystem_uuid: request.fetch(:ecosystem_uuid),
        events: gapless_event_hashes,
        is_stopped_at_gap: is_gap
      }
    end

    { ecosystem_event_responses: responses }
  end
end
