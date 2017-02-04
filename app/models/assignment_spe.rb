class AssignmentSpe < ActiveRecord::Base
  include HasUniqueUuid

  validates :assignment_uuid, presence: true, uniqueness: true
end
