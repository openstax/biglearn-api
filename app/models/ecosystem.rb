class Ecosystem < ApplicationRecord
  include UniqueUuid
  include MetadataSequenceNumber

  has_many :ecosystem_events, primary_key: :uuid,
                              foreign_key: :ecosystem_uuid,
                              inverse_of: :ecosystem
  has_many :book_containers, primary_key: :uuid,
                             foreign_key: :ecosystem_uuid,
                             inverse_of: :ecosystem

  validates :sequence_number,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
