require 'rails_helper'

RSpec.describe CourseStudent, type: :model do

  let(:container) { FactoryGirl.build(:course_container) }

  it 'can be built from factory' do
    student = FactoryGirl.build(:course_student)
    expect(student.save).to be true
  end

  it 'must have a valid container' do
    student = CourseStudent.new container_uuid: SecureRandom.uuid,
                                student_uuid: SecureRandom.uuid
    expect(student.save).not_to be true
    expect(student.errors[:container].first).to match 'blank'
  end

  it 'can be created and saved' do
    student = CourseStudent.new student_uuid: SecureRandom.uuid, container: container
    expect(student.save).to be true
  end

  it "can be created and saved from the container" do
    student = container.students.build student_uuid: SecureRandom.uuid
    expect(student.save).to be true
    expect(container.students.length).to be(1)
  end
end
