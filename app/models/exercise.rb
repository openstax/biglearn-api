class Exercise < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  validates :exercises_uuid, presence: true
  validates :exercises_version, presence: true, uniqueness: { scope: :exercises_uuid }
  # TODO: validate that the los array contains only strings
end
