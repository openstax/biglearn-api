# This code will not return events with gaps in the sequence_number
class Services::FetchEcosystemEvents::Service < Services::ApplicationService
  EVENT_LIMIT = 10000     # Sent to Postgres as the LIMIT clause
  MAX_DATA_SIZE = 1000000 # For the data field, in characters

  def process(ecosystem_event_requests:)
    # Return the request_uuid that caused each record to be returned
    request_uuid_cases = ecosystem_event_requests.map do |request|
      sequence_number_offset = request.fetch(:sequence_number_offset)

      <<-CASE_SQL.strip_heredoc
        WHEN "ecosystem_uuid" = #{EcosystemEvent.sanitize(request.fetch(:ecosystem_uuid))}
          AND "sequence_number" >= #{EcosystemEvent.sanitize(sequence_number_offset)}
        THEN #{EcosystemEvent.sanitize(request.fetch(:request_uuid))}
      CASE_SQL
    end.join(' ')

    ce = EcosystemEvent.arel_table
    # Build a single query that returns the requested events using OR
    event_query = ArelTrees.or_tree(
      ecosystem_event_requests.map do |request|
        ce[:ecosystem_uuid].eq(request.fetch(:ecosystem_uuid))
          .and(ce[:sequence_number].gteq(request.fetch(:sequence_number_offset)))
          .and(ce[:type].in(request.fetch(:event_types)))
      end
    )

    # Also return gap information about each record
    ecosystem_event_sql = EcosystemEvent.select(
      <<-SQL.strip_heredoc
        "ecosystem_events"."sequence_number",
        "ecosystem_events"."uuid",
        "ecosystem_events"."type",
        "ecosystem_events"."data",
        CASE WHEN "ecosystem_events"."sequence_number" > 0
          AND NOT EXISTS (
            SELECT "previous_event".*
            FROM "ecosystem_events" AS "previous_event"
            WHERE "previous_event"."ecosystem_uuid" = "ecosystem_events"."ecosystem_uuid"
              AND "previous_event"."sequence_number" = "ecosystem_events"."sequence_number" - 1
          ) THEN TRUE
        ELSE FALSE
        END AS "is_after_gap",
        CASE #{request_uuid_cases} END AS "request_uuid"
      SQL
    )
    .where(event_query)
    .order(:ecosystem_uuid, :sequence_number)
    .limit(EVENT_LIMIT)
    .to_sql

    # Stream the data from Postgres and stop when the size limit is exceeded
    connection = EcosystemEvent.connection.raw_connection
    decoder = PG::TextDecoder::CopyRow.new
    data_size = 0
    is_size_limited = false
    num_events = 0
    ecosystem_events_by_request_uuid = Hash.new { |hash, key| hash[key] = [] }
    connection.copy_data "COPY (#{ecosystem_event_sql}) TO STDOUT", decoder do
      while row = connection.get_copy_data
        if data_size >= MAX_DATA_SIZE
          is_size_limited = true

          next
        end

        num_events += 1
        data_size += row.fourth.size
        ecosystem_events_by_request_uuid[row[5]] << row
      end
    end

    is_end = !is_size_limited && num_events < EVENT_LIMIT

    responses = ecosystem_event_requests.map do |request|
      request_uuid = request.fetch(:request_uuid)

      ecosystem_events = ecosystem_events_by_request_uuid[request_uuid] || []
      is_gap = false
      event_hashes = ecosystem_events.map do |event|
        is_gap = true if event.fifth == 't'

        next if is_gap

        {
          sequence_number: event.first.to_i,
          event_uuid: event.second,
          event_type: EcosystemEvent.types.key(event.third.to_i),
          event_data: JSON.parse(event.fourth)
        }
      end.compact

      # If we detected a gap, this means we are not sending some EcosystemEvents,
      # so this is not the end of the sequence
      # If we didn't detect a gap, then we check if we returned
      # less than the number of EcosystemEvents requested
      {
        request_uuid: request_uuid,
        ecosystem_uuid: request.fetch(:ecosystem_uuid),
        events: event_hashes,
        is_gap: is_gap,
        is_end: is_end && !is_gap
      }
    end

    { ecosystem_event_responses: responses }
  end
end
