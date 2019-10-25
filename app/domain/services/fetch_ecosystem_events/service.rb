# This code will not return events with gaps in the sequence_number
class Services::FetchEcosystemEvents::Service < Services::ApplicationService
  MAX_DATA_SIZE = 3.2e7 # For the data field, in bits

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
    active_ecosystem_uuids = Set.new Ecosystem.joins(
      <<-JOIN_SQL.strip_heredoc
        INNER JOIN (#{ValuesTable.new(ecosystem_event_values_array)})
          AS "requests" ("ecosystem_uuid", "sequence_number_offset", "event_types", "request_uuid")
          ON "ecosystems"."uuid" = "requests"."ecosystem_uuid"::uuid
            AND "ecosystems"."sequence_number" > "requests"."sequence_number_offset"
      JOIN_SQL
    ).pluck(:uuid)

    unless active_ecosystem_uuids.empty?
      active_ecosystem_event_values = ecosystem_event_values_array.select do |ecosystem_event_value|
        active_ecosystem_uuids.include? ecosystem_event_value.first
      end

      # Also return gap information about each record
      ecosystem_events = EcosystemEvent
        .from("(#{
          EcosystemEvent.select(
            <<-SELECT_SQL.strip_heredoc
              "ecosystem_events"."sequence_number",
              "ecosystem_events"."uuid",
              "ecosystem_events"."type",
              "ecosystem_events"."data",
              ROW_NUMBER() OVER "window" AS "row_number",
              SUM(BIT_LENGTH("ecosystem_events"."data"::text)) OVER "window" AS "cumulative_size",
              CASE WHEN "ecosystem_events"."sequence_number" > 0
                AND NOT EXISTS (
                  SELECT "previous_event".*
                  FROM "ecosystem_events" AS "previous_event"
                  WHERE "previous_event"."ecosystem_uuid" = "ecosystem_events"."ecosystem_uuid"
                    AND "previous_event"."sequence_number" =
                      "ecosystem_events"."sequence_number" - 1
                ) THEN TRUE
              ELSE FALSE
              END AS "is_after_gap",
              CASE WHEN NOT EXISTS (
                SELECT "next_events".*
                FROM "ecosystem_events" AS "next_events"
                WHERE "next_events"."ecosystem_uuid" = "ecosystem_events"."ecosystem_uuid"
                  AND "next_events"."sequence_number" > "ecosystem_events"."sequence_number"
                  AND "next_events"."type" = ANY("requests"."event_types")
              ) THEN TRUE
              ELSE FALSE
              END AS "is_end",
              "requests"."request_uuid"
            SELECT_SQL
          )
          .joins(
            <<-JOIN_SQL.strip_heredoc
              RIGHT OUTER JOIN (#{ValuesTable.new(active_ecosystem_event_values)}) AS "requests"
                ("ecosystem_uuid", "sequence_number_offset", "event_types", "request_uuid")
                ON "ecosystem_events"."ecosystem_uuid" = "requests"."ecosystem_uuid"::uuid
                  AND "ecosystem_events"."sequence_number" >= "requests"."sequence_number_offset"
                  AND "ecosystem_events"."type" = ANY("requests"."event_types")
              WINDOW "window" AS (
                ORDER BY "ecosystem_events"."sequence_number" - "requests"."sequence_number_offset"
                  ASC NULLS FIRST
                ROWS UNBOUNDED PRECEDING
              )
            JOIN_SQL
          )
          .order(
            Arel.sql(
              <<-ORDER_SQL.strip_heredoc
                "ecosystem_events"."sequence_number" - "requests"."sequence_number_offset"
                ASC NULLS FIRST
              ORDER_SQL
            )
          )
          .limit(max_num_events)
          .to_sql
        }) AS \"ecosystem_events\"")
        .where(
          <<-WHERE_SQL.strip_heredoc
            "row_number" = 1
              OR "cumulative_size" IS NULL
              OR "cumulative_size" < #{MAX_DATA_SIZE.to_i}
          WHERE_SQL
        )
      ecosystem_events_by_request_uuid = ecosystem_events.group_by(&:request_uuid)
    end

    responses = ecosystem_event_requests.map do |request|
      request_uuid = request.fetch(:request_uuid)
      ecosystem_uuid = request.fetch(:ecosystem_uuid)

      # Inactive ecosystem
      next {
        request_uuid: request_uuid,
        ecosystem_uuid: ecosystem_uuid,
        events: [],
        is_gap: false,
        is_end: true
      } unless active_ecosystem_uuids.include? ecosystem_uuid

      # Limit reached before the first row for this request could be processed
      next {
        request_uuid: request_uuid,
        ecosystem_uuid: ecosystem_uuid,
        events: [],
        is_gap: false,
        is_end: false
      } if !ecosystem_events_by_request_uuid.has_key?(request_uuid)

      is_gap = false
      ecosystem_events = ecosystem_events_by_request_uuid[request_uuid]
      event_hashes = ecosystem_events.map do |ecosystem_event|
        is_gap = true if ecosystem_event.is_after_gap
        next if is_gap

        uuid = ecosystem_event.uuid
        next if uuid.nil?

        {
          sequence_number: ecosystem_event.sequence_number,
          event_uuid: uuid,
          event_type: ecosystem_event.type,
          event_data: ecosystem_event.data
        }
      end.compact

      {
        request_uuid: request_uuid,
        ecosystem_uuid: ecosystem_uuid,
        events: event_hashes,
        is_gap: is_gap,
        is_end: !is_gap && ecosystem_events.last.is_end
      }
    end

    { ecosystem_event_responses: responses }
  end
end
