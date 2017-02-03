class AssignmentSpe < ActiveRecord::Base
  include HasUniqueUuid

  belongs_to :assignment, primary_key: :assignment_uuid,
                          foreign_key: :assignment_uuid,
                          inverse_of: :assignment_spe

  validates :assignment_uuid, presence: true, uniqueness: true
end
