class CourseContainer < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  belongs_to :course, primary_key: :uuid,
                      foreign_key: :course_uuid,
                      inverse_of: :course_containers

  has_many :roster_containers, primary_key: :uuid,
                               foreign_key: :container_uuid,
                               inverse_of: :course_container
  has_many :course_rosters, through: :roster_containers

  has_many :teacher_clues, primary_key: :uuid,
                           foreign_key: :course_container_uuid,
                           inverse_of: :course_container

  validates :course_uuid, presence: true
end
