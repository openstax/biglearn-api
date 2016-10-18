require 'rails_helper'

RSpec.describe CourseContainer, type: :model do

  let(:course) { FactoryGirl.build(:course) }
  let(:fresh_container) {
    CourseContainer.new course: course,
                        parent_container_uuid: SecureRandom.uuid,
                        container_uuid: SecureRandom.uuid
  }
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
    expect(fresh_container.save).to be true
  end

  it "can be created and saved from the course" do
    course.containers.build container_uuid: SecureRandom.uuid, parent_container_uuid: SecureRandom.uuid
    expect(course.save).to be true
    expect(course.containers.length).to be(1)
  end

  it 'wont be deleted if it has any students' do
    student = fresh_container.students.build student_uuid: SecureRandom.uuid
    fresh_container.save
    fresh_container.destroy
    expect(fresh_container.errors[:students].first).to match 'Cannot delete'
    expect {
             course.containers.where(container_uuid: fresh_container.container_uuid).destroy_all
    }.not_to change{ course.containers.count }
    # can be deleted after student is removed
    student.destroy
    expect {
             course.containers.where(container_uuid: fresh_container.container_uuid).destroy_all
    }.to change{ course.containers.count }.by(-1)

  end

end
