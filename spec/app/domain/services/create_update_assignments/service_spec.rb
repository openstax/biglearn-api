require 'rails_helper'

RSpec.describe Services::CreateUpdateAssignments::Service, type: :service do
  let(:service)                                 { described_class.new }

  let(:given_assignment_uuid)                   { SecureRandom.uuid }
  let(:given_sequence_number)                   { rand(10) }
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
        assignment_uuid: given_assignment_uuid,
        sequence_number: given_sequence_number,
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

  context "when a previously-existing assignment_uuid and sequence_number combo is given" do
    before(:each) do
      FactoryGirl.create(:assignment, assignment_uuid: given_assignment_uuid,
                                      sequence_number: given_sequence_number)
    end

    it "an Assignment is NOT created" do
      expect{action}.not_to change{Assignment.count}
    end

    it "the Assignment's assignment_uuid and sequence_number are returned" do
      expect(action.fetch(:updated_assignments)).to eq(
        [
          {
            assignment_uuid: given_assignment_uuid,
            sequence_number: given_sequence_number
          }
        ]
      )
    end
  end

  context "when a previously non-existing assignment_uuid and sequence_number combo is given" do
    it "an Assignment is created, as well as associated records with the correct attributes" do
      given_assigned_exercises_by_trial_uuid = given_assigned_exercises.index_by do |hash|
        hash[:trial_uuid]
      end

      expect{action}.to change{Assignment.count}.by(given_assignments.size)
                    .and change{AssignedExercise.count}.by(given_assigned_exercises.size)

      assignment = Assignment.find_by(assignment_uuid: given_assignment_uuid,
                                      sequence_number: given_sequence_number)
      expect(assignment.is_deleted).to eq given_is_deleted
      expect(assignment.ecosystem_uuid).to eq given_ecosystem_uuid
      expect(assignment.student_uuid).to eq given_student_uuid
      expect(assignment.assignment_type).to eq given_assignment_type
      expect(assignment.assigned_book_container_uuids).to eq given_assigned_book_container_uuids
      expect(assignment.goal_num_tutor_assigned_spes).to eq given_goal_num_tutor_assigned_spes
      expect(assignment.spes_are_assigned).to eq given_spes_are_assigned
      expect(assignment.goal_num_tutor_assigned_pes).to eq given_goal_num_tutor_assigned_pes
      expect(assignment.pes_are_assigned).to eq given_pes_are_assigned

      assignment.assigned_exercises.each do |assigned_exercise|
        trial_uuid = assigned_exercise[:trial_uuid]
        given_assigned_exercise = given_assigned_exercises_by_trial_uuid[trial_uuid]

        expect(assigned_exercise.exercise_uuid).to eq given_assigned_exercise[:exercise_uuid]
        expect(assigned_exercise.exercise_uuid).to eq given_assigned_exercise[:exercise_uuid]
        expect(assigned_exercise.exercise_uuid).to eq given_assigned_exercise[:exercise_uuid]
      end
    end

    it "the Assignment's assignment_uuid and sequence_number are returned" do
      expect(action.fetch(:updated_assignments)).to eq(
        [
          {
            assignment_uuid: given_assignment_uuid,
            sequence_number: given_sequence_number
          }
        ]
      )
    end
  end
end
