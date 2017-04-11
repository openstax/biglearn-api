class BookContainer < ApplicationRecord
  include AppendOnlyWithUniqueUuid

  validates :ecosystem_uuid, presence: true
end
