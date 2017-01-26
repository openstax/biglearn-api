class CourseRoster < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  belongs_to :course, primary_key: :uuid,
                      foreign_key: :course_uuid,
                      inverse_of: :course_rosters

  has_many :roster_containers, primary_key: :uuid,
                               foreign_key: :roster_uuid,
                               inverse_of: :course_roster
  has_many :course_containers, through: :roster_containers

  has_many :roster_students, primary_key: :uuid,
                             foreign_key: :roster_uuid,
                             inverse_of: :course_roster
  has_many :students, through: :roster_students

  validates :course_uuid, presence: true
  validates :sequence_number, presence: true,
                              uniqueness: { scope: :course_uuid, case_sensitive: false },
                              numericality: { greater_than_or_equal_to: 0 }
end
