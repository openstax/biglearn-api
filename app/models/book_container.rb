class BookContainer < ActiveRecord::Base
  include AppendOnlyWithUniqueUuid

  validates :ecosystem_uuid, presence: true
end
