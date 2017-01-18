class Response < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid
end
