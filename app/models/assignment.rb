class Assignment < ApplicationRecord
  # This record is only used to determine if we know about a certain assignment or not
  include AppendOnlyWithUniqueUuid
end
