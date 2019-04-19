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
    event_1_attributes = FactoryGirl.build(:course_event).attributes.merge(
      sequence_number_association_extra_attributes: {
        initial_ecosystem_uuid: SecureRandom.uuid,
      }
    )
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

  it 'creates the associated record or updates its sequence_number' do
    course_uuid = SecureRandom.uuid
    ecosystem_uuid = SecureRandom.uuid
    event_1_attributes = FactoryGirl.build(
      :course_event, course: nil, course_uuid: course_uuid, sequence_number: 0
    ).attributes.merge(
      sequence_number_association_extra_attributes: {
        initial_ecosystem_uuid: ecosystem_uuid,
      }
    )
    expect{ test_class.append [ event_1_attributes ] }.to change { Course.count }.by(1)
    course = Course.find_by! uuid: course_uuid
    expect(course.sequence_number).to eq 1
    expect(course.initial_ecosystem_uuid).to eq ecosystem_uuid

    event_2_attributes = FactoryGirl.build(
      :course_event, course: course, sequence_number: 1
    ).attributes
    event_3_attributes = FactoryGirl.build(
      :course_event, course: course, sequence_number: 3
    ).attributes
    attributes_array = [ event_2_attributes, event_3_attributes ]

    expect{ test_class.append attributes_array }.to(
      change { course.reload.sequence_number }.from(1).to(4)
    )
    expect(course.initial_ecosystem_uuid).to eq ecosystem_uuid

    event_4_attributes = FactoryGirl.build(
      :course_event, course: course, sequence_number: 2
    ).attributes

    expect{ test_class.append [ event_4_attributes ] }.not_to(
      change { course.reload.sequence_number }
    )
    expect(course.initial_ecosystem_uuid).to eq ecosystem_uuid
  end
end
