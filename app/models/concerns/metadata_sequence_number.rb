module MetadataSequenceNumber
  extend ActiveSupport::Concern

  included do
    validates :metadata_sequence_number,
              presence: true,
              uniqueness: true,
              numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    before_validation :set_metadata_sequence_number
  end

  def set_metadata_sequence_number
    self.metadata_sequence_number ||= (self.class.maximum(:metadata_sequence_number) || -1) + 1
    self
  end
end
