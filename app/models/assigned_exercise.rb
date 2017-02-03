class AssignedExercise < ActiveRecord::Base
  # The assignment_uuid column refers to an Assignment's uuid column (NOT assignment_uuid)

  include AppendOnly
  include HasUniqueUuid

  belongs_to :assignment, primary_key: :uuid,
                          foreign_key: :assignment_uuid,
                          inverse_of: :assigned_exercises

  belongs_to :exercise, primary_key: :uuid,
                        foreign_key: :exercise_uuid,
                        inverse_of: :assigned_exercises

  validates :assignment,    presence: true
  validates :exercise_uuid, presence: true, uniqueness: { scope: :assignment_uuid }
end
