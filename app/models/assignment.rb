class Assignment < ApplicationRecord
  # This record is only used to determine if we know about a certain assignment or not
  include AppendOnlyWithUniqueUuid

  has_many :assignment_pes, primary_key: :uuid,
                            foreign_key: :assignment_uuid,
                            inverse_of: :assignment
  has_many :assignment_spes, primary_key: :uuid,
                             foreign_key: :assignment_uuid,
                             inverse_of: :assignment
end
