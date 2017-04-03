class StudentPe < ActiveRecord::Base
  include HasUniqueUuid

  belongs_to :student, primary_key: :uuid,
                       foreign_key: :student_uuid,
                       inverse_of: :student_pe

  validates :student_uuid,   presence: true
  validates :algorithm_name, presence: true, uniqueness: { scope: :student_uuid }
end
