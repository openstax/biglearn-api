class CourseContainer < ActiveRecord::Base
  # This record is only used to determine if we know about a certain course container or not
  include AppendOnly
  include HasUniqueUuid
end
