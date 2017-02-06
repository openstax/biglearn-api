class Student < ActiveRecord::Base
  # This record is only used to determine if we know about a certain student or not
  include AppendOnlyWithUniqueUuid
end
