class EcosystemEvent < ApplicationRecord
  self.inheritance_column = nil

  include AppendOnlyWithUniqueUuid

  enum type: {
    create_ecosystem: 0
  }

  # Returns the last record before the each gap in sequence_numbers for each ecosystem
  # Always includes the last existing record for each ecosystem
  scope :before_gap, ->(ecosystem_uuids: nil) do
    query = where(
      from('"ecosystem_events" "next_event"').where(
        <<-SQL.strip_heredoc
          "next_event"."ecosystem_uuid" = "ecosystem_events"."ecosystem_uuid"
            AND "next_event"."sequence_number" = "ecosystem_events"."sequence_number" + 1
        SQL
      ).exists.not
    )

    ecosystem_uuids.nil? ? query : query.where(ecosystem_uuid: ecosystem_uuids)
  end

  # Same as above, but also numbers each gap
  scope :before_gap_with_ecosystem_gap_number, ->(ecosystem_uuids: nil) do
    from(
      <<-OUTERSQL
        (
          #{
            before_gap(ecosystem_uuids: ecosystem_uuids).select(
              <<-INNERSQL.strip_heredoc
                "ecosystem_events".*,
                  row_number() OVER (
                    PARTITION BY "ecosystem_events"."ecosystem_uuid"
                    ORDER BY "ecosystem_events"."sequence_number"
                  ) AS "ecosystem_gap_number"
              INNERSQL
            ).to_sql
          }
        ) AS "ecosystem_events"
      OUTERSQL
    )
  end

  validates :type,            presence: true
  validates :ecosystem_uuid,  presence: true
  validates :sequence_number, presence: true,
                              uniqueness: { scope: :ecosystem_uuid },
                              numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
