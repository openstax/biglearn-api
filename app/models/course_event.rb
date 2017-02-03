class CourseEvent < ActiveRecord::Base
  VALID_EVENT_TYPES = [
    :create_course,
    :prepare_course_ecosystem,
    :update_course_ecosystems,
    :update_rosters,
    :update_globally_excluded_exercises,
    :update_course_excluded_exercises,
    :create_update_assignments
  ].map(&:to_s)

  include AppendOnly
  include HasUniqueUuid

  self.inheritance_column = nil

  belongs_to :course, primary_key: :uuid,
                      foreign_key: :course_uuid,
                      inverse_of: :course_events

  validates :type,            presence: true,
                              inclusion: { in: VALID_EVENT_TYPES }
  validates :course_uuid,     presence: true
  validates :sequence_number, presence: true,
                              uniqueness: { scope: :course_uuid },
                              numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
