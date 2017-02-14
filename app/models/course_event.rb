class CourseEvent < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  enum event_type: {
    create_course:                      0,
    prepare_course_ecosystem:           1,
    update_course_ecosystems:           2,
    update_rosters:                     3,
    update_course_active_dates:         4,
    update_globally_excluded_exercises: 5,
    update_course_excluded_exercises:   6,
    create_update_assignments:          7,
    record_responses:                   8
  }

  belongs_to :course, primary_key: :uuid,
                      foreign_key: :course_uuid,
                      inverse_of: :course_events

  validates :event_type,      presence: true
  validates :course_uuid,     presence: true
  validates :sequence_number, presence: true,
                              uniqueness: { scope: :course_uuid },
                              numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
