class GlobalExerciseExclusion < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  validates :sequence_number, presence: true,
                              uniqueness: true,
                              numericality: { greater_than_or_equal_to: 0 }
end
