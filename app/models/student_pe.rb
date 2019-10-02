class StudentPe < ApplicationRecord
  belongs_to :student, primary_key: :uuid,
                       foreign_key: :student_uuid,
                       optional: true,
                       inverse_of: :student_pes

  validates :calculation_uuid, presence: true
  validates :student_uuid,     presence: true
  validates :algorithm_name,   presence: true, uniqueness: { scope: :student_uuid }
end
