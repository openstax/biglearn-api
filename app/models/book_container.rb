class BookContainer < ActiveRecord::Base
  # This record is only used to determine if we know about a certain book container or not
  include AppendOnly
  include HasUniqueUuid
end
