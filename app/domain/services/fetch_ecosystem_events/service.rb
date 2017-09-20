# This code will not return events with gaps in the sequence_number
class Services::FetchEcosystemEvents::Service < Services::ApplicationService
  MAX_DATA_SIZE = 1000000 # For the data field, in characters

  def process(ecosystem_event_requests:, max_num_events:)
    return { ecosystem_event_responses: [] } if ecosystem_event_requests.empty?

    ecosystem_event_values_array = ecosystem_event_requests.map do |request|
      [
        request.fetch(:ecosystem_uuid),
        request.fetch(:sequence_number_offset),
        EcosystemEvent.types.values_at(*request.fetch(:event_types)),
        request.fetch(:request_uuid)
      ]
    end
    ecosystem_event_join_query = <<-JOIN_SQL
      INNER JOIN (#{ValuesTable.new(ecosystem_event_values_array)})
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
    .joins(ecosystem_event_join_query)
    .order('"requests"."request_uuid" ASC', :sequence_number)
    .limit(max_num_events)
    .to_sql

    # Stream the data from Postgres and stop when the size limit is exceeded
    connection = EcosystemEvent.connection.raw_connection
    decoder = PG::TextDecoder::CopyRow.new
    data_size = 0
    num_events = 0
    ecosystem_events_by_request_uuid = Hash.new { |hash, key| hash[key] = [] }
    last_processed_request_uuid = nil
    connection.copy_data "COPY (#{ecosystem_event_sql}) TO STDOUT", decoder do
      while row = connection.get_copy_data
        request_uuid = row[5]
        num_events += 1

        next if data_size >= MAX_DATA_SIZE

        last_processed_request_uuid = request_uuid
        data_size += row.fourth.size
        ecosystem_events_by_request_uuid[request_uuid] << row
      end
    end

    # If we didn't hit either the size of the event number limit, then all requests were completed
    all_requests_completed = data_size < MAX_DATA_SIZE && num_events < max_num_events

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

      # If all requests were completed, any requests without a gap reached the end
      # Otherwise, only requests that sort before the last_processed_request_uuid reached the end
      is_end = !is_gap && (all_requests_completed || request_uuid < last_processed_request_uuid)

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
