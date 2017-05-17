require 'rails_helper'

RSpec.describe AppendOnlyWithUniqueUuid, type: :concern do
  let(:test_class)    { CourseEvent }

  let(:test_instance) { FactoryGirl.build(:course_event) }

  it 'makes instances of the including class append-only' do
    expect(test_instance.new_record?).to eq true
    expect(test_instance.readonly?).to eq false
    test_instance.save
    expect(test_instance.new_record?).to eq false
    expect(test_instance.readonly?).to eq true
  end

  it 'provides an append method' do
    expect(test_class).to respond_to(:append)
  end

  it 'can import multiple records through append' do
    event_1_attributes = FactoryGirl.build(:course_event).attributes
    event_2_attributes = FactoryGirl.build(:course_event).attributes
    attributes_array = [ event_1_attributes, event_2_attributes ]

    expect{test_class.append attributes_array}.to change{test_class.count}.by(2)
    expect{test_class.append attributes_array}.not_to change{test_class.count}

    # We expect the import to explode if the same course_uuid and sequence_number
    # are used with a different event uuid
    conflicting_attributes = [event_1_attributes.merge('uuid' => SecureRandom.uuid)]
    expect{test_class.append conflicting_attributes}.to(
      raise_error(ActiveRecord::RecordNotUnique)
    )
  end
end
