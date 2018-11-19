class StudentClue < ApplicationRecord
  belongs_to :student, primary_key: :uuid,
                       foreign_key: :student_uuid,
                       optional: true,
                       inverse_of: :student_clues
  belongs_to :book_container, primary_key: :uuid,
                              foreign_key: :book_container_uuid,
                              optional: true,
                              inverse_of: :student_clues

  validates :student_uuid,        presence: true
  validates :book_container_uuid, presence: true
  validates :algorithm_name,      presence: true,
                                  uniqueness: { scope: [:student_uuid, :book_container_uuid] }
  validates :data,                presence: true
end
