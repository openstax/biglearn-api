class Bundle::ResponseBundle < ActiveRecord::Base
  include HasUniqueUuid

  validates :partition_value, presence: true
end
