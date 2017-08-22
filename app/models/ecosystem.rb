class Ecosystem < ApplicationRecord
  include AppendOnlyWithUniqueUuid
  include MetadataSequenceNumber
end
