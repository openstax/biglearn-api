class Student < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  belongs_to :course, primary_key: :uuid,
                      foreign_key: :course_uuid,
                      inverse_of: :students

  has_many :roster_students, primary_key: :uuid,
                             foreign_key: :student_uuid,
                             inverse_of: :student
  has_many :course_rosters, through: :roster_students

  has_many :assignments, primary_key: :uuid,
                         foreign_key: :student_uuid,
                         inverse_of: :student

  has_one :student_pe, primary_key: :uuid,
                       foreign_key: :student_uuid,
                       inverse_of: :student

  validates :course_uuid, presence: true
end
