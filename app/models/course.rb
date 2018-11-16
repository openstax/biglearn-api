class Course < ApplicationRecord
  include AppendOnlyWithUniqueUuid
  include MetadataSequenceNumber

  validates :initial_ecosystem_uuid,  presence: true
end
