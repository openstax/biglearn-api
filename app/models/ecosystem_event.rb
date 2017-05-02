class EcosystemEvent < ApplicationRecord
  self.inheritance_column = nil

  include AppendOnlyWithUniqueUuid

  enum type: {
    create_ecosystem: 0
  }

  # Returns the last record before the each gap in sequence_numbers for each ecosystem
  # Always includes the last existing record for each ecosystem
  scope :before_gap, -> do
    joins(
      <<-SQL.strip_heredoc
        LEFT OUTER JOIN ecosystem_events ecosystem_event_gaps
          ON ecosystem_event_gaps.ecosystem_uuid = ecosystem_events.ecosystem_uuid
            AND ecosystem_event_gaps.sequence_number = ecosystem_events.sequence_number + 1
      SQL
    ).where(ecosystem_event_gaps: { id: nil })
  end

  # Same as above, but also numbers each gap
  scope :before_gap_with_ecosystem_gap_number, -> do
    from(
      <<-OUTERSQL
        (
          #{
            before_gap.select(
              <<-INNERSQL.strip_heredoc
                ecosystem_events.*,
                  row_number() OVER (
                    PARTITION BY ecosystem_events.ecosystem_uuid
                    ORDER BY ecosystem_events.sequence_number
                  ) AS ecosystem_gap_number
              INNERSQL
            ).to_sql
          }
        ) AS ecosystem_events
      OUTERSQL
    )
  end

  validates :type,            presence: true
  validates :ecosystem_uuid,  presence: true
  validates :sequence_number, presence: true,
                              uniqueness: { scope: :ecosystem_uuid },
                              numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
