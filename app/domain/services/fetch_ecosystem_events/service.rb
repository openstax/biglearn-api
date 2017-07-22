# This code will not return events with gaps in the sequence_number
class Services::FetchEcosystemEvents::Service < Services::ApplicationService
  MAX_EVENTS = 10

  def process(ecosystem_event_requests:)
    # Build a single query that returns the requested events using UNION ALL
    num_requests = ecosystem_event_requests.size
    max_events_per_request = MAX_EVENTS/num_requests
    limits_by_request_uuid = {}
    ee = EcosystemEvent.arel_table
    event_query = ArelTrees.union_all_tree(
      ecosystem_event_requests.map do |request|
        ecosystem_uuid = request.fetch(:ecosystem_uuid)
        sequence_number_offset = request.fetch(:sequence_number_offset)
        request_uuid = request.fetch(:request_uuid)
        limit = [request.fetch(:max_num_events, max_events_per_request), max_events_per_request].min
        limits_by_request_uuid[request_uuid] = limit

        ee.where(
          ee[:ecosystem_uuid].eq(ecosystem_uuid)
            .and(ee[:sequence_number].gteq(sequence_number_offset))
            .and(ee[:type].in(request.fetch(:event_types)))
        )
        .order(:sequence_number)
        .project(ee[Arel.star], "'#{request_uuid}' AS \"request_uuid\"")
        .take(limit)
      end
    )

    # http://radar.oreilly.com/2014/05/more-than-enough-arel.html
    from_query = ee.create_table_alias(event_query, :ecosystem_events)

    # Also return gap information with each record
    ecosystem_events_by_request_uuid = event_query.nil? ?
      {} :
      EcosystemEvent.from(from_query).select(
        <<-SQL.strip_heredoc
          "ecosystem_events".*, CASE WHEN "ecosystem_events"."sequence_number" > 0
            AND NOT EXISTS (
              SELECT "previous_event".*
              FROM "ecosystem_events" AS "previous_event"
              WHERE "previous_event"."ecosystem_uuid" = "ecosystem_events"."ecosystem_uuid"
                AND "previous_event"."sequence_number" = "ecosystem_events"."sequence_number" - 1
            ) THEN TRUE
          ELSE FALSE
          END AS "is_after_gap"
        SQL
      ).group_by(&:request_uuid)

    responses = ecosystem_event_requests.map do |request|
      request_uuid = request.fetch(:request_uuid)

      ecosystem_events = ecosystem_events_by_request_uuid[request_uuid] || []
      is_gap = false
      event_hashes = ecosystem_events.map do |event|
        is_gap = true if event.is_after_gap

        next if is_gap

        {
          sequence_number: event.sequence_number,
          event_uuid: event.uuid,
          event_type: event.type,
          event_data: event.data
        }
      end.compact

      # If we detected a gap, this means we are not sending some EcosystemEvents,
      # so this is not the end of the sequence
      # If we didn't detect a gap, then we check if we returned
      # less than the number of EcosystemEvents requested
      is_end = !is_gap && limits_by_request_uuid.fetch(request_uuid) > ecosystem_events.size

      {
        request_uuid: request_uuid,
        ecosystem_uuid: request.fetch(:ecosystem_uuid),
        events: event_hashes,
        is_gap: is_gap,
        is_end: is_end
      }
    end

    { ecosystem_event_responses: responses }
  end
end
