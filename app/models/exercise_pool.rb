class ExercisePool < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  belongs_to :book_container, primary_key: :uuid,
                              foreign_key: :container_uuid,
                              inverse_of: :exercise_pools
  has_one :book, through: :book_container

  validates :book_container, presence: true
end
