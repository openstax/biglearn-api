class EcosystemUpdateReady < ActiveRecord::Base
  # This record is only used to determine if a given ecosystem preparation/update is ready
  include AppendOnlyWithUniqueUuid

  validates :preparation_uuid, presence: true, uniqueness: true
end
