class StudentPe < ApplicationRecord
  validates :student_uuid,   presence: true
  validates :algorithm_name, presence: true, uniqueness: { scope: :student_uuid }
end
