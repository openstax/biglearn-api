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
      RIGHT OUTER JOIN (#{ValuesTable.new(ecosystem_event_values_array)})
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
        CASE WHEN NOT EXISTS (
          SELECT "next_events".*
          FROM "ecosystem_events" AS "next_events"
          WHERE "next_events"."ecosystem_uuid" = "ecosystem_events"."ecosystem_uuid"
            AND "next_events"."sequence_number" > "ecosystem_events"."sequence_number"
            AND "next_events"."type" = ANY ("requests"."event_types")
        ) THEN TRUE
        ELSE FALSE
        END AS "is_end",
        "requests"."request_uuid"
      SQL
    )
    .joins(ecosystem_event_join_query)
    .order(
      '"ecosystem_events"."sequence_number" - "requests"."sequence_number_offset" ASC NULLS FIRST'
    )
    .limit(max_num_events)
    .to_sql

    # Stream the data from Postgres and stop when the size limit is exceeded
    connection = EcosystemEvent.connection.raw_connection
    decoder = PG::TextDecoder::CopyRow.new
    total_data_size = 0
    rows_by_request_uuid = Hash.new { |hash, key| hash[key] = [] }
    connection.copy_data "COPY (#{ecosystem_event_sql}) TO STDOUT", decoder do
      while row = connection.get_copy_data
        data_size = row.fourth.nil? ? 0 : row.fourth.size
        next if data_size > 0 && total_data_size >= MAX_DATA_SIZE

        total_data_size += data_size
        request_uuid = row[6]
        rows_by_request_uuid[request_uuid] << row
      end
    end

    responses = ecosystem_event_requests.map do |request|
      request_uuid = request.fetch(:request_uuid)
      ecosystem_uuid = request.fetch(:ecosystem_uuid)

      # Limit reached before the first row for this request could be processed
      next {
        request_uuid: request_uuid,
        ecosystem_uuid: ecosystem_uuid,
        events: [],
        is_gap: false,
        is_end: false
      } if !rows_by_request_uuid.has_key?(request_uuid)

      is_gap = false
      rows = rows_by_request_uuid[request_uuid]
      event_hashes = rows.map do |row|
        is_gap = true if row.fifth == 't'

        next if is_gap || row.fourth.nil?

        {
          sequence_number: row.first.to_i,
          event_uuid: row.second,
          event_type: EcosystemEvent.types.key(row.third.to_i),
          event_data: JSON.parse(row.fourth)
        }
      end.compact

      {
        request_uuid: request_uuid,
        ecosystem_uuid: ecosystem_uuid,
        events: event_hashes,
        is_gap: is_gap,
        is_end: !is_gap && rows.last[5] == 't'
      }
    end

    { ecosystem_event_responses: responses }
  end
end
