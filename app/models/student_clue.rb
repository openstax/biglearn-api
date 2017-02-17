class StudentClue < ActiveRecord::Base
  include HasUniqueUuid

  validates :student_uuid,        presence: true
  validates :book_container_uuid, presence: true, uniqueness: { scope: :student_uuid }
  validates :data,                presence: true
end
