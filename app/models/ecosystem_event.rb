class EcosystemEvent < ApplicationRecord
  self.inheritance_column = nil

  include AppendOnlyWithUniqueUuid

  belongs_to :ecosystem, primary_key: :uuid,
                         foreign_key: :ecosystem_uuid,
                         inverse_of: :ecosystem_events

  sequence_number_association :ecosystem

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
