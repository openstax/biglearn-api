class Exercise < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  has_many :assigned_exercises, primary_key: :uuid,
                                foreign_key: :exercise_uuid,
                                inverse_of: :exercise

  validates :exercises_uuid,    presence: true
  validates :exercises_version, presence: true, uniqueness: { scope: :exercises_uuid }
end
