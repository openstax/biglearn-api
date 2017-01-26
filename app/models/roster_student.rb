class RosterStudent < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  belongs_to :course_roster, primary_key: :uuid,
                             foreign_key: :roster_uuid,
                             inverse_of: :roster_students

  belongs_to :roster_container, primary_key: :uuid,
                                foreign_key: :roster_container_uuid,
                                inverse_of: :roster_students

  belongs_to :student, primary_key: :uuid,
                       foreign_key: :student_uuid,
                       inverse_of: :roster_students
  has_one :course, through: :student

  validates :course_roster,    presence: true
  validates :roster_container, presence: true
  validates :student,          presence: true
  validates :student_uuid,     uniqueness: { scope: :roster_container_uuid }
  validate  :same_roster, :same_course

  protected

  def same_roster
    return if course_roster.nil? || roster_container.nil? ||
              roster_container.course_roster == course_roster
    errors.add(:roster_container, 'must belong to the same course_roster')
    false
  end

  def same_course
    return if course_roster.nil? || student.nil? || course_roster.course_uuid == student.course_uuid
    errors.add(:course_uuid, 'must be the same for the course_roster and student')
    false
  end
end
