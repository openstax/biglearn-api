require 'rails_helper'

RSpec.describe Services::UpdateRosters::Service, type: :service do
  let(:service)                                        { described_class.new }

  let(:given_request_uuid)                             { SecureRandom.uuid }
  let(:given_course)                                   { FactoryGirl.create :course }
  let(:given_course_uuid)                              { given_course.uuid }
  let(:given_sequence_number)                          { rand(10) }

  let(:given_course_container_1_uuid)                  { SecureRandom.uuid }
  let(:given_course_container_1_parent_container_uuid) { given_course_container_1_uuid }
  let(:given_course_container_1_created_at)            { Time.current.iso8601(6) }
  let(:given_course_container_1_archived_at)           { Time.current.iso8601(6) }
  let(:given_course_container_2_uuid)                  { SecureRandom.uuid }
  let(:given_course_container_2_parent_container_uuid) { given_course_container_1_uuid }
  let(:given_course_container_2_created_at)            { Time.current.iso8601(6) }
  let(:given_course_container_2_archived_at)           { nil }

  let(:given_course_containers)                        do
    [
      {
        container_uuid: given_course_container_1_uuid,
        parent_container_uuid: given_course_container_1_parent_container_uuid,
        created_at: given_course_container_1_created_at,
        archived_at: given_course_container_1_archived_at
      },
      {
        container_uuid: given_course_container_2_uuid,
        parent_container_uuid: given_course_container_2_parent_container_uuid,
        created_at: given_course_container_2_created_at,
        archived_at: given_course_container_2_archived_at
      }
    ]
  end

  let(:given_student_1_uuid)                            { SecureRandom.uuid }
  let(:given_student_1_container_uuid)                  { given_course_container_1_uuid }
  let(:given_student_1_enrolled_at)                     { Time.current.iso8601(6) }
  let(:given_student_1_last_course_container_change_at) { Time.current.iso8601(6) }
  let(:given_student_1_dropped_at)                      { Time.current.iso8601(6) }
  let(:given_student_2_uuid)                            { SecureRandom.uuid }
  let(:given_student_2_container_uuid)                  { given_course_container_1_uuid }
  let(:given_student_2_enrolled_at)                     { Time.current.iso8601(6) }
  let(:given_student_2_last_course_container_change_at) { Time.current.iso8601(6) }
  let(:given_student_2_dropped_at)                      { Time.current.iso8601(6) }
  let(:given_student_3_uuid)                            { SecureRandom.uuid }
  let(:given_student_3_container_uuid)                  { given_course_container_2_uuid }
  let(:given_student_3_enrolled_at)                     { Time.current.iso8601(6) }
  let(:given_student_3_last_course_container_change_at) { Time.current.iso8601(6) }
  let(:given_student_3_dropped_at)                      { Time.current.iso8601(6) }
  let(:given_students)                                  do
    [
      {
        student_uuid: given_student_1_uuid,
        container_uuid: given_student_1_container_uuid,
        enrolled_at: given_student_1_enrolled_at,
        last_course_container_change_at: given_student_1_last_course_container_change_at,
        dropped_at: given_student_1_dropped_at
      },
      {
        student_uuid: given_student_2_uuid,
        container_uuid: given_student_2_container_uuid,
        enrolled_at: given_student_2_enrolled_at,
        last_course_container_change_at: given_student_2_last_course_container_change_at,
        dropped_at: given_student_2_dropped_at
      },
      {
        student_uuid: given_student_3_uuid,
        container_uuid: given_student_3_container_uuid,
        enrolled_at: given_student_3_enrolled_at,
        last_course_container_change_at: given_student_3_last_course_container_change_at,
        dropped_at: given_student_3_dropped_at
      }
    ]
  end

  let(:given_rosters)                                  do
    [
      {
        request_uuid: given_request_uuid,
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
          p given_course
      FactoryGirl.create :course_event,
                         course_uuid: given_course_uuid,
                         sequence_number: given_sequence_number
    end

    it "a CourseEvent is NOT created and an error is returned" do
      expect{action}.to not_change{CourseEvent.count}
                    .and raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  context "when a previously non-existing course_uuid and sequence_number combination is given" do
    it "a CourseEvent is created, as well as associated records with the correct attributes" do
      expect{action}.to change{CourseEvent.count}.by(given_rosters.size)
                    .and change{CourseContainer.count}.by(given_course_containers.size)
                    .and change{Student.count}.by(given_students.size)

      update_rosters = CourseEvent.find_by(
        course_uuid: given_course_uuid, sequence_number: given_sequence_number
      )
      data = update_rosters.data.deep_symbolize_keys
      expect(data.fetch(:course_containers)).to eq given_course_containers
      expect(data.fetch(:students)).to eq given_students

      new_container_uuids = given_course_containers.map { |container| container.fetch(:container_uuid) }
      new_container_uuids.each do |container_uuid|
        expect(CourseContainer.exists?(uuid: container_uuid)).to eq true
      end

      new_student_uuids = given_students.map { |student| student.fetch(:student_uuid) }
      new_student_uuids.each do |student_uuid|
        expect(Student.exists?(uuid: student_uuid)).to eq true
      end
    end

    it "the Course's uuid is returned with the request_uuid" do
      updated_roster = action.fetch(:updated_rosters).first

      expect(updated_roster.fetch(:request_uuid)).to eq given_request_uuid
      expect(updated_roster.fetch(:updated_course_uuid)).to eq given_course_uuid
    end
  end
end
