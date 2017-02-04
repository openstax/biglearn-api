require 'rails_helper'

RSpec.describe EcosystemEvent, type: :model do
  subject { FactoryGirl.create :ecosystem_event }

  it { is_expected.to validate_presence_of :ecosystem_uuid }
  it { is_expected.to validate_presence_of :sequence_number }
  it { is_expected.to validate_presence_of :event_type }

  it do
    is_expected.to(
      validate_uniqueness_of(:sequence_number).scoped_to(:ecosystem_uuid).case_insensitive
    )
  end

  it do
    is_expected.to(
      validate_numericality_of(:sequence_number).only_integer.is_greater_than_or_equal_to(0)
    )
  end

  it 'can import multiple events through standard_import' do
    event_1_attributes = FactoryGirl.build(:ecosystem_event).attributes
    event_2_attributes = FactoryGirl.build(:ecosystem_event).attributes
    attributes_array = [ event_1_attributes, event_2_attributes ]

    expect{described_class.standard_import attributes_array}.to change{described_class.count}.by(2)
    expect{described_class.standard_import attributes_array}.not_to change{described_class.count}

    # We expect the import to explode if the same ecosystem_uuid and sequence_number
    # are used with a different event uuid
    conflicting_attributes = [event_1_attributes.merge('uuid' => SecureRandom.uuid)]
    expect{described_class.standard_import conflicting_attributes}.to(
      raise_error(ActiveRecord::RecordNotUnique)
    )
  end
end
