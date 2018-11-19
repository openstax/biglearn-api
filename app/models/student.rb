class Student < ApplicationRecord
  # This record is only used to determine if we know about a certain student or not
  include AppendOnlyWithUniqueUuid

  has_many :student_clues, primary_key: :uuid,
                           foreign_key: :student_uuid,
                           inverse_of: :student
  has_many :student_pes, primary_key: :uuid,
                         foreign_key: :student_uuid,
                         inverse_of: :student
end
