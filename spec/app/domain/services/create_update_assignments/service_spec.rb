require 'rails_helper'

RSpec.describe Services::CreateUpdateAssignments::Service, type: :service do
  let(:service)                                 { described_class.new }

  let(:given_request_uuid)                      { SecureRandom.uuid }
  let(:given_course_uuid)                       { SecureRandom.uuid }
  let(:given_sequence_number)                   { rand(10) }
  let(:given_assignment_uuid)                   { SecureRandom.uuid }
  let(:given_is_deleted)                        { false }
  let(:given_ecosystem_uuid)                    { SecureRandom.uuid }
  let(:given_student_uuid)                      { SecureRandom.uuid }
  let(:given_assignment_type)                   { 'reading' }
  let(:given_assigned_book_container_uuid)      { SecureRandom.uuid }
  let(:given_assigned_book_container_uuids)     { [ given_assigned_book_container_uuid ] }
  let(:given_goal_num_tutor_assigned_spes)      { 2 }
  let(:given_spes_are_assigned)                 { true }
  let(:given_goal_num_tutor_assigned_pes)       { 1 }
  let(:given_pes_are_assigned)                  { false }

  let(:given_assigned_exercise_1_trial_uuid)    { SecureRandom.uuid }
  let(:given_assigned_exercise_1_exercise_uuid) { SecureRandom.uuid }
  let(:given_assigned_exercise_1_is_spe)        { true }
  let(:given_assigned_exercise_1_is_pe)         { false }

  let(:given_assigned_exercise_2_trial_uuid)    { SecureRandom.uuid }
  let(:given_assigned_exercise_2_exercise_uuid) { SecureRandom.uuid }
  let(:given_assigned_exercise_2_is_spe)        { false }
  let(:given_assigned_exercise_2_is_pe)         { true }

  let(:given_assigned_exercises)                do
    [
      {
        trial_uuid: given_assigned_exercise_1_trial_uuid,
        exercise_uuid: given_assigned_exercise_1_exercise_uuid,
        is_spe: given_assigned_exercise_1_is_spe,
        is_pe: given_assigned_exercise_1_is_pe
      },
      {
        trial_uuid: given_assigned_exercise_2_trial_uuid,
        exercise_uuid: given_assigned_exercise_2_exercise_uuid,
        is_spe: given_assigned_exercise_2_is_spe,
        is_pe: given_assigned_exercise_2_is_pe
      }
    ]
  end

  let(:given_assignments)                       do
    [
      {
        request_uuid: given_request_uuid,
        course_uuid: given_course_uuid,
        sequence_number: given_sequence_number,
        assignment_uuid: given_assignment_uuid,
        is_deleted: given_is_deleted,
        ecosystem_uuid: given_ecosystem_uuid,
        student_uuid: given_student_uuid,
        assignment_type: given_assignment_type,
        assigned_book_container_uuids: given_assigned_book_container_uuids,
        goal_num_tutor_assigned_spes: given_goal_num_tutor_assigned_spes,
        spes_are_assigned: given_spes_are_assigned,
        goal_num_tutor_assigned_pes: given_goal_num_tutor_assigned_pes,
        pes_are_assigned: given_pes_are_assigned,
        assigned_exercises: given_assigned_exercises
      }
    ]
  end

  let(:action)                                  { service.process(assignments: given_assignments) }

  context "when a previously-existing course_uuid and sequence_number combo is given" do
    before(:each) do
      FactoryGirl.create(:course_event, course_uuid: given_course_uuid,
                                        sequence_number: given_sequence_number)
    end

    it "a CourseEvent and an Assignment are NOT created and an error is returned" do
      expect{action}.to not_change{CourseEvent.count}
                    .and not_change{Assignment.count}
                    .and raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  context "when a previously non-existing course_uuid and sequence_number combo is given" do
    it "a CourseEvent and an Assignment are created with the correct attributes" do
      given_assigned_exercises_by_trial_uuid = given_assigned_exercises.index_by do |hash|
        hash.fetch(:trial_uuid)
      end

      expect{action}.to change{CourseEvent.count}.by(given_assignments.size)
                    .and change{Assignment.count}.by(given_assignments.size)

      event = CourseEvent.find_by(course_uuid: given_course_uuid,
                                  sequence_number: given_sequence_number)
      data = event.data.deep_symbolize_keys
      expect(data.fetch(:assignment_uuid)).to eq given_assignment_uuid
      expect(data.fetch(:is_deleted)).to eq given_is_deleted
      expect(data.fetch(:ecosystem_uuid)).to eq given_ecosystem_uuid
      expect(data.fetch(:student_uuid)).to eq given_student_uuid
      expect(data.fetch(:assignment_type)).to eq given_assignment_type
      expect(data.fetch(:assigned_book_container_uuids)).to eq given_assigned_book_container_uuids
      expect(data.fetch(:goal_num_tutor_assigned_spes)).to eq given_goal_num_tutor_assigned_spes
      expect(data.fetch(:spes_are_assigned)).to eq given_spes_are_assigned
      expect(data.fetch(:goal_num_tutor_assigned_pes)).to eq given_goal_num_tutor_assigned_pes
      expect(data.fetch(:pes_are_assigned)).to eq given_pes_are_assigned

      data.fetch(:assigned_exercises).each do |assigned_exercise|
        trial_uuid = assigned_exercise.fetch(:trial_uuid)
        given_assigned_exercise = given_assigned_exercises_by_trial_uuid[trial_uuid]

        expect(assigned_exercise.fetch(:exercise_uuid)).to eq(
          given_assigned_exercise.fetch(:exercise_uuid)
        )
        expect(assigned_exercise.fetch(:is_spe)).to eq given_assigned_exercise.fetch(:is_spe)
        expect(assigned_exercise.fetch(:is_pe)).to eq given_assigned_exercise.fetch(:is_pe)
      end

      expect(Assignment.exists?(uuid: given_assignment_uuid)).to eq true
    end

    it "the assignment_uuid and sequence_number are returned" do
      expect(action.fetch(:updated_assignments)).to eq(
        [ { request_uuid: given_request_uuid, updated_assignment_uuid: given_assignment_uuid } ]
      )
    end
  end
end
