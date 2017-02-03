class CourseActiveDate < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  belongs_to :course, primary_key: :uuid,
                      foreign_key: :course_uuid,
                      inverse_of: :course_active_dates

  validates :course_uuid,     presence: true
  validates :sequence_number, presence: true, uniqueness: { scope: :course_uuid }
end
