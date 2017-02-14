class EcosystemPreparationReady < ActiveRecord::Base
  # This record is only used to determine if a given ecosystem preparation is ready
  include AppendOnlyWithUniqueUuid
end
