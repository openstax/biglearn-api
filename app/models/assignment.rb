class Assignment < ActiveRecord::Base
  # The uuid column is unique per-record
  # The assignment_uuid column may be repeated with different sequence_numbers
  # Joins are done based on the uuid column

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

  has_one :assignment_pe, primary_key: :uuid,
                          foreign_key: :assignment_uuid,
                          inverse_of: :assignment

  has_one :assignment_spe, primary_key: :uuid,
                           foreign_key: :assignment_uuid,
                           inverse_of: :assignment

  validates :assignment_uuid,              presence: true
  validates :sequence_number,              presence: true, uniqueness: { scope: :assignment_uuid }
  validates :ecosystem_uuid,               presence: true
  validates :student_uuid,                 presence: true
  validates :assignment_type,              presence: true
  validates :goal_num_tutor_assigned_spes, presence: true
  validates :goal_num_tutor_assigned_pes,  presence: true
end
