class RosterContainer < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  belongs_to :course_roster, primary_key: :uuid,
                             foreign_key: :roster_uuid,
                             inverse_of: :roster_containers
  has_one :course, through: :course_roster

  belongs_to :course_container, primary_key: :uuid,
                                foreign_key: :container_uuid,
                                inverse_of: :roster_containers

  belongs_to :parent_roster_container, class_name: name,
                                       primary_key: :uuid,
                                       foreign_key: :parent_roster_container_uuid,
                                       inverse_of: :child_roster_containers

  has_many :child_roster_containers, class_name: name,
                                     primary_key: :uuid,
                                     foreign_key: :parent_roster_container_uuid,
                                     inverse_of: :parent_roster_container

  has_many :roster_students, primary_key: :uuid,
                             foreign_key: :container_uuid,
                             inverse_of: :roster_container
  has_many :students, through: :roster_students

  validates :course_roster, presence: true
  validates :course_container, presence: true
  validates :container_uuid, uniqueness: { scope: :roster_uuid, case_sensitive: false }
  validate  :same_course

  protected

  def same_course
    return if course_roster.nil? || course_container.nil? ||
              course_roster.course_uuid == course_container.course_uuid
    errors.add(:course_uuid, 'must be the same for the course_roster and course_container')
    false
  end
end
