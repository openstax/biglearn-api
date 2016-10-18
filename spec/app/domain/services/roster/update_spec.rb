require 'rails_helper'


RSpec.describe Services::Roster::Update do

  context "when given a course and new students" do

    let(:course){ FactoryGirl.create(:course) }
    let(:roster){ { 'course_uuid' => course.uuid } }
    let(:update) { Services::Roster::Update.new({'rosters' => [roster]}) }
    let(:container){
      course.containers.create!(container_uuid: SecureRandom.uuid)
    }
    let(:student){
      container.students.create!(student_uuid: SecureRandom.uuid)
    }
    let(:new_containers) {
      Array.new(3){ { 'container_uuid' => SecureRandom.uuid.to_s } }
    }
    let(:new_students) {
      Array.new(10){ { 'student_uuid'   => SecureRandom.uuid.to_s,
                       'container_uuid' => new_containers.sample['container_uuid'] } }
    }

    it "creates records that are new" do
      roster.merge!('course_containers' => new_containers,'students' => new_students)
      update.process!
      expect(course.students(true).length).to be(10)
    end

    it 'removes old ones' do
      old_student_uuid = student.student_uuid
      expect(course.students(true).pluck(:student_uuid)).to include(old_student_uuid)
      roster.merge!('course_containers' => new_containers, 'students' => new_students)
      update.process!
      expect(course.students(true).pluck(:student_uuid)).to_not include(old_student_uuid)
    end

    it 'leaves existing records alone' do
      roster.merge!(
        'course_containers' => [student.container.as_json],
        'students' => [student.as_json]
      )
      update.process!
      expect(CourseStudent.exists?(student.id)).to be true
      expect(course.students(true).length).to be(1)
    end

  end

end
