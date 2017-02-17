class TeacherClue < ActiveRecord::Base
  include HasUniqueUuid

  validates :course_container_uuid, presence: true
  validates :book_container_uuid,   presence: true, uniqueness: { scope: :course_container_uuid }
  validates :data,                  presence: true
end
