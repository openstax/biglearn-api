class Assignment < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  belongs_to :ecosystem, primary_key: :uuid,
                         foreign_key: :ecosystem_uuid,
                         inverse_of: :assignments

  belongs_to :student, primary_key: :uuid,
                       foreign_key: :student_uuid,
                       inverse_of: :assignments

  has_many :assigned_exercises, primary_key: :uuid,
                                foreign_key: :assignment_uuid,
                                inverse_of: :assignment
  has_many :exercises, through: :assigned_exercises

  validates :assignment_uuid,              presence: true
  validates :sequence_number,              presence: true, uniqueness: { scope: :assignment_uuid }
  validates :ecosystem_uuid,               presence: true
  validates :student_uuid,                 presence: true
  validates :assignment_type,              presence: true
  validates :goal_num_tutor_assigned_spes, presence: true
  validates :goal_num_tutor_assigned_pes,  presence: true
  # TODO: Validate that assigned_book_container_uuids contains only UUIDs
end
