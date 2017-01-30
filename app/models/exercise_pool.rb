class ExercisePool < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  belongs_to :book_container, primary_key: :uuid,
                              foreign_key: :container_uuid,
                              inverse_of: :exercise_pools
  has_one :book, through: :book_container

  validates :book_container, presence: true
  validates :use_for_clue, inclusion: { in: [true, false] }
  # TODO: validate that the use_for_personalized_for_assignment_types array contains only strings
  # TODO: validate that the exercises_uuids array contains only uuids
end
