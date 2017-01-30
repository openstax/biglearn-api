class TeacherClue < ActiveRecord::Base
  include HasUniqueUuid

  belongs_to :course_container, primary_key: :uuid,
                                foreign_key: :course_container_uuid,
                                inverse_of: :teacher_clues

  belongs_to :book_container, primary_key: :uuid,
                              foreign_key: :book_container_uuid,
                              inverse_of: :teacher_clues

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
