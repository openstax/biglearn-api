class CourseEvent < ApplicationRecord
  self.inheritance_column = nil

  include AppendOnlyWithUniqueUuid

  enum type: {
    create_course:                      0,
    prepare_course_ecosystem:           1,
    update_course_ecosystem:            2,
    update_roster:                      3,
    update_course_active_dates:         4,
    update_globally_excluded_exercises: 5,
    update_course_excluded_exercises:   6,
    create_update_assignment:           7,
    record_response:                    8
  }

  # Returns the last record before the each gap in sequence_numbers for each course
  # Always includes the last existing record for each course
  scope :before_gap, -> do
    joins(
      <<-SQL.strip_heredoc
        LEFT OUTER JOIN course_events course_event_gaps
          ON course_event_gaps.course_uuid = course_events.course_uuid
            AND course_event_gaps.sequence_number = course_events.sequence_number + 1
      SQL
    ).where(course_event_gaps: { id: nil })
  end

  # Same as above, but also numbers each gap
  scope :before_gap_with_course_gap_number, -> do
    from(
      <<-OUTERSQL
        (
          #{
            before_gap.select(
              <<-INNERSQL.strip_heredoc
                course_events.*,
                  row_number() OVER (
                    PARTITION BY course_events.course_uuid
                    ORDER BY course_events.sequence_number
                  ) AS course_gap_number
              INNERSQL
            ).to_sql
          }
        ) AS course_events
      OUTERSQL
    )
  end

  validates :type,            presence: true
  validates :course_uuid,     presence: true
  validates :sequence_number, presence: true,
                              uniqueness: { scope: :course_uuid },
                              numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
