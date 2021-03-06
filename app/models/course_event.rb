class CourseEvent < ApplicationRecord
  self.inheritance_column = nil

  include AppendOnlyWithUniqueUuid

  belongs_to :course, primary_key: :uuid,
                      foreign_key: :course_uuid,
                      inverse_of: :course_events

  sequence_number_association :course

  enum type: {
    no_op:                              -1,
    create_course:                       0,
    prepare_course_ecosystem:            1,
    update_course_ecosystem:             2,
    update_roster:                       3,
    update_course_active_dates:          4,
    update_globally_excluded_exercises:  5,
    update_course_excluded_exercises:    6,
    create_update_assignment:            7,
    record_response:                     8
  }

  validates :type,            presence: true
  validates :course_uuid,     presence: true
  validates :sequence_number, presence: true,
                              uniqueness: { scope: :course_uuid },
                              numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
