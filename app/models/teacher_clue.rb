class TeacherClue < ApplicationRecord
  belongs_to :course_container, primary_key: :uuid,
                                foreign_key: :course_container_uuid,
                                optional: true,
                                inverse_of: :teacher_clues
  belongs_to :book_container, primary_key: :uuid,
                              foreign_key: :book_container_uuid,
                              optional: true,
                              inverse_of: :teacher_clues

  validates :calculation_uuid,      presence: true
  validates :course_container_uuid, presence: true
  validates :book_container_uuid,   presence: true
  validates :algorithm_name,        presence: true,
                                    uniqueness: {
                                      scope: [:course_container_uuid, :book_container_uuid]
                                    }
  validates :data,                  presence: true
end
