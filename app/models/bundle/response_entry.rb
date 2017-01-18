class Bundle::ResponseEntry < ActiveRecord::Base
  include HasUniqueUuid

  validates :bundle_uuid, presence: true
end
