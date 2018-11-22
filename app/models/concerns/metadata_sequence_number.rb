module MetadataSequenceNumber
  extend ActiveSupport::Concern

  included do
    validates :metadata_sequence_number,
              uniqueness: { allow_nil: true },
              numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_nil: true }
  end
end
