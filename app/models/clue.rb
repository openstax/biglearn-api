class Clue < ActiveRecord::Base
  enum confidence: [ :bad, :good ]
  enum level:      [ :low, :medium, :high ]
  enum threshold:  [ :above, :below ]
end
