class TeacherClue < ApplicationRecord
  validates :course_container_uuid, presence: true
  validates :book_container_uuid,   presence: true
  validates :algorithm_name,        presence: true,
                                    uniqueness: {
                                      scope: [:course_container_uuid, :book_container_uuid]
                                    }
  validates :data,                  presence: true
end
