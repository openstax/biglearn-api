module HasUniqueUuid
  extend ActiveSupport::Concern

  included { validates :uuid, presence: true, uniqueness: true }
end
