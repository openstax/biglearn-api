require 'rails_helper'

RSpec.describe MetadataSequenceNumber, type: :concern do
  let(:test_class) do
    Class.new do
      def self.validates(*args)
      end
    end
  end

  it 'sets up validations for the metadata_sequence_number field' do
    expect(test_class).to receive(:validates).with(
      :metadata_sequence_number, uniqueness: { allow_nil: true }, numericality: {
        only_integer: true, greater_than_or_equal_to: 0, allow_nil: true
      }
    )
    test_class.class_exec { include MetadataSequenceNumber }
  end
end
