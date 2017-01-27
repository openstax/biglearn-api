require 'rails_helper'

RSpec.describe Services::UpdateRoster::Service, type: :service do
  let(:service)                                        { described_class.new }

  let(:given_course_uuid)                              { SecureRandom.uuid }
  let(:given_sequence_number)                          { rand(10) }

  let(:given_course_container_1_uuid)                  { SecureRandom.uuid }
  let(:given_course_container_1_parent_container_uuid) { given_course_container_1_uuid }
  let(:given_course_container_1_is_archived)           { true }
  let(:given_course_container_2_uuid)                  { SecureRandom.uuid }
  let(:given_course_container_2_parent_container_uuid) { given_course_container_1_uuid }
  let(:given_course_container_2_is_archived)           { false }
  let(:given_course_containers)                        do
    [
      {
        container_uuid: given_course_container_1_uuid,
        parent_container_uuid: given_course_container_1_parent_container_uuid,
        is_archived: given_course_container_1_is_archived
      },
      {
        container_uuid: given_course_container_2_uuid,
        parent_container_uuid: given_course_container_2_parent_container_uuid,
        is_archived: given_course_container_2_is_archived
      }
    ]
  end

  let(:given_student_1_uuid)                           { SecureRandom.uuid }
  let(:given_student_1_container_uuid)                 { given_course_container_1_uuid }
  let(:given_student_2_uuid)                           { SecureRandom.uuid }
  let(:given_student_2_container_uuid)                 { given_course_container_1_uuid }
  let(:given_student_3_uuid)                           { SecureRandom.uuid }
  let(:given_student_3_container_uuid)                 { given_course_container_2_uuid }
  let(:given_students)                                 do
    [
      {
        student_uuid: given_student_1_uuid,
        container_uuid: given_student_1_container_uuid
      },
      {
        student_uuid: given_student_2_uuid,
        container_uuid: given_student_2_container_uuid,
      },
      {
        student_uuid: given_student_3_uuid,
        container_uuid: given_student_3_container_uuid
      }
    ]
  end

  let(:given_rosters)                                  do
    [
      {
        course_uuid: given_course_uuid,
        sequence_number: given_sequence_number,
        course_containers: given_course_containers,
        students: given_students
      }
    ]
  end

  let(:action)                                         { service.process(rosters: given_rosters) }

  context "when a previously-existing course_uuid and sequence_number combination is given" do
    before(:each) do
      FactoryGirl.create :course_roster,
                         course_uuid: given_course_uuid, sequence_number: given_sequence_number
    end

    it "a CourseRoster is NOT created" do
      expect{action}.not_to change{CourseRoster.count}
    end

    it "the Course's uuid is returned" do
      expect(action.fetch(:updated_course_uuids)).to eq [given_course_uuid]
    end
  end

  context "when a previously non-existing course_uuid and sequence_number combination is given" do
    it "a CourseRoster is created, as well as associated records with the correct attributes" do
      expect{action}.to change{CourseRoster.count}.by(given_rosters.size)
                    .and change{CourseContainer.count}.by(given_course_containers.size)
                    .and change{Student.count}.by(given_students.size)
                    .and change{RosterContainer.count}.by(given_course_containers.size)
                    .and change{RosterStudent.count}.by(given_students.size)

      new_container_uuids = given_course_containers.map { |container| container[:container_uuid] }
      new_container_uuids.each do |container_uuid|
        container = CourseContainer.find_by(uuid: container_uuid)

        expect(container.course_uuid).to eq given_course_uuid
      end

      new_student_uuids = given_students.map { |student| student[:student_uuid] }
      new_student_uuids.each do |student_uuid|
        student = Student.find_by(uuid: student_uuid)

        expect(student.course_uuid).to eq given_course_uuid
      end

      course_roster = CourseRoster.find_by(course_uuid: given_course_uuid,
                                           sequence_number: given_sequence_number)
      roster_containers = course_roster.roster_containers
      expect(roster_containers.length).to eq given_course_containers.size
      roster_containers.each do |roster_container|
        expect(new_container_uuids).to include(roster_container.container_uuid)
      end

      roster_students = course_roster.roster_students
      expect(roster_students.length).to eq given_students.size
      roster_students.each do |roster_student|
        expect(new_container_uuids).to include(roster_student.roster_container.container_uuid)
        expect(new_student_uuids).to include(roster_student.student_uuid)
      end
    end

    it "the Course's uuid is returned" do
      expect(action.fetch(:updated_course_uuids)).to eq [given_course_uuid]
    end
  end
end
