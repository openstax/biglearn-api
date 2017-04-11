class EcosystemPreparationReady < ApplicationRecord
  # This record is only used to determine if a given ecosystem preparation is ready
  include AppendOnlyWithUniqueUuid
end
