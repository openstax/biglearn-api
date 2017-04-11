class AssignmentSpe < ApplicationRecord
  validates :assignment_uuid, presence: true
  validates :algorithm_name,  presence: true, uniqueness: { scope: :assignment_uuid }
end
