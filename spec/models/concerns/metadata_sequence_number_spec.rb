require 'rails_helper'

RSpec.describe MetadataSequenceNumber, type: :concern do
  let(:test_class) do
    Class.new do
      def self.validates(*args)
      end

      def self.before_validation(*args)
      end
    end
  end

  it 'sets up validations for the metadata_sequence_number field' do
    expect(test_class).to receive(:validates).with(
      :metadata_sequence_number, presence: true, uniqueness: true,
                                 numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    )
    test_class.class_exec { include MetadataSequenceNumber }
  end

  it 'automatically assigns a metadata_sequence_number before validation' do
    expect(test_class).to receive(:before_validation).with(:set_metadata_sequence_number)
    test_class.class_exec { include MetadataSequenceNumber }

    ecosystem = Ecosystem.new(uuid: SecureRandom.uuid)
    expect(ecosystem.metadata_sequence_number).to be_nil
    expect(ecosystem).to be_valid
    expect(ecosystem.metadata_sequence_number).to be >= 0
  end
end
