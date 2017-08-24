# This code will not return events with gaps in the sequence_number
class Services::FetchEcosystemEvents::Service < Services::ApplicationService
  MAX_DATA_SIZE = 1000000 # For the data field, in characters

  def process(ecosystem_event_requests:, max_num_events:)
    return { ecosystem_event_responses: [] } if ecosystem_event_requests.empty?

    # Using a join on VALUES is faster than multiple OR queries
    event_values = ecosystem_event_requests.map do |request|
      "(#{
        [
          "#{EcosystemEvent.sanitize(request.fetch(:ecosystem_uuid))}::uuid",
          EcosystemEvent.sanitize(request.fetch(:sequence_number_offset)),
          "'{#{EcosystemEvent.types.values_at(*request.fetch(:event_types)).join(',')}}'::int[]",
          "#{EcosystemEvent.sanitize(request.fetch(:request_uuid))}::uuid"
        ].join(', ')
      })"
    end
    join_query = <<-JOIN_SQL
      INNER JOIN (VALUES #{event_values.join(', ')})
        AS "requests" ("ecosystem_uuid", "sequence_number_offset", "event_types", "request_uuid")
        ON "ecosystem_events"."ecosystem_uuid" = "requests"."ecosystem_uuid"
          AND "ecosystem_events"."sequence_number" >= "requests"."sequence_number_offset"
          AND "ecosystem_events"."type" = ANY ("requests"."event_types")
    JOIN_SQL

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
        "requests"."request_uuid"
      SQL
    )
    .joins(join_query)
    .order('"requests"."request_uuid" ASC', :sequence_number)
    .limit(max_num_events)
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

    is_limited = is_size_limited || num_events >= max_num_events

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

      # If we ran into the event limit or detected a gap, this means we are not sending some
      # EcosystemEvents, so this is not the end of the sequence
      {
        request_uuid: request_uuid,
        ecosystem_uuid: request.fetch(:ecosystem_uuid),
        events: event_hashes,
        is_gap: is_gap,
        is_end: !is_limited && !is_gap
      }
    end

    { ecosystem_event_responses: responses }
  end
end
