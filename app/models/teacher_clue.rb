class TeacherClue < ActiveRecord::Base
  include HasUniqueUuid

  validates :course_container_uuid, presence: true
  validates :book_container_uuid,   presence: true, uniqueness: { scope: :course_container_uuid }
  validates :aggregate,             presence: true, numericality: { greater_than_or_equal_to: 0,
                                                                    less_than_or_equal_to: 1 }
  validates :confidence_left,       presence: true, numericality: { greater_than_or_equal_to: 0,
                                                                    less_than_or_equal_to: 1 }
  validates :confidence_right,      presence: true, numericality: { greater_than_or_equal_to: 0,
                                                                    less_than_or_equal_to: 1 }
  validates :sample_size,           presence: true, numericality: { only_integer: true,
                                                                    greater_than_or_equal_to: 0 }
  validates :unique_learner_count,  presence: true, numericality: { only_integer: true,
                                                                    greater_than_or_equal_to: 0 }
end
