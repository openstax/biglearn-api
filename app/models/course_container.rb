class CourseContainer < ApplicationRecord
  # This record is only used to determine if we know about a certain course container or not
  include AppendOnlyWithUniqueUuid

  has_many :teacher_clues, primary_key: :uuid,
                           foreign_key: :course_container_uuid,
                           inverse_of: :course_container
end
