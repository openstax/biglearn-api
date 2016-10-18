require 'rails_helper'

RSpec.describe CourseContainer, type: :model do

  let(:course) { FactoryGirl.build(:course) }

  it 'can be built from factory' do
    container = FactoryGirl.build(:course_container)
    expect(container.save).to be true
  end

  it 'must have a valid course' do
    container = CourseContainer.new container_uuid: SecureRandom.uuid, course_uuid: SecureRandom.uuid
    expect(container.save).not_to be true
    expect(container.errors[:course].first).to match 'blank'
  end

  it 'can be created and saved' do
    container = CourseContainer.new course: course,
                                    parent_container_uuid: SecureRandom.uuid,
                                    container_uuid: SecureRandom.uuid
    expect(container.save).to be true
  end

  it "can be created and saved from the course" do
    course.containers.build container_uuid: SecureRandom.uuid, parent_container_uuid: SecureRandom.uuid
    expect(course.save).to be true
    expect(course.containers.length).to be(1)
  end

end
