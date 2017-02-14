class StudentClue < ActiveRecord::Base
  include HasUniqueUuid

  validates :student_uuid,        presence: true
  validates :book_container_uuid, presence: true, uniqueness: { scope: :student_uuid }
  validates :aggregate,           presence: true, numericality: { greater_than_or_equal_to: 0,
                                                                  less_than_or_equal_to: 1 }
  validates :confidence_left,     presence: true, numericality: { greater_than_or_equal_to: 0,
                                                                  less_than_or_equal_to: 1 }
  validates :confidence_right,    presence: true, numericality: { greater_than_or_equal_to: 0,
                                                                  less_than_or_equal_to: 1 }
  validates :sample_size,         presence: true, numericality: { only_integer: true,
                                                                  greater_than_or_equal_to: 0 }

  def unique_learner_count
    1
  end
end
