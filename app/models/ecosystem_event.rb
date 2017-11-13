class EcosystemEvent < ApplicationRecord
  self.inheritance_column = nil

  include NotifyingAppendOnlyWithUniqueUuid
  self.notify_payload_method = :ecosystem_uuid

  enum type: {
    no_op:            -1,
    create_ecosystem:  0
  }

  validates :type,            presence: true
  validates :ecosystem_uuid,  presence: true
  validates :sequence_number, presence: true,
                              uniqueness: { scope: :ecosystem_uuid },
                              numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
