class AssignmentPe < ApplicationRecord
  belongs_to :assignment, primary_key: :uuid,
                          foreign_key: :assignment_uuid,
                          optional: true,
                          inverse_of: :assignment_pes

  validates :calculation_uuid, presence: true
  validates :assignment_uuid,  presence: true
  validates :algorithm_name,   presence: true, uniqueness: { scope: :assignment_uuid }
end
