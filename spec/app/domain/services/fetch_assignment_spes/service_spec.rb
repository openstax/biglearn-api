require 'rails_helper'

RSpec.describe Services::FetchAssignmentSpes::Service, type: :service do
  let(:service)                   { described_class.new }

  let(:given_assignment_uuid_1)   { SecureRandom.uuid }
  let(:given_max_num_exercises_1) { rand(10) + 1 }
  let(:given_assignment_uuid_2)   { SecureRandom.uuid }
  let(:given_max_num_exercises_2) { rand(10) + 1 }

  let(:given_spe_requests)        do
    [
      { assignment_uuid: given_assignment_uuid_1, max_num_exercises: given_max_num_exercises_1 },
      { assignment_uuid: given_assignment_uuid_2, max_num_exercises: given_max_num_exercises_2 }
    ]
  end

  let(:action)                    { service.process(spe_requests: given_spe_requests) }

  let(:given_assignment_uuids)    { [ given_assignment_uuid_1, given_assignment_uuid_2 ] }

  context "when non-existing AssignmentSpe assignment_uuids are given" do
    context "when non-existing Assignment uuids are given" do
      it "the assignment_uuids are returned with assignment_status: 'assignment_unknown'" do
        action.fetch(:spe_responses).each do |response|
          expect(given_assignment_uuids).to include response.fetch(:assignment_uuid)
          expect(response.fetch(:exercise_uuids)).to eq []
          expect(response.fetch(:assignment_status)).to eq 'assignment_unknown'
        end
      end
    end

    context "when previously-existing Assignment uuids are given" do
      before do
        given_assignment_uuids.each do |assignment_uuid|
          FactoryGirl.create :assignment, assignment_uuid: assignment_uuid
        end
      end

      it "the assignment_uuids are returned with assignment_status: 'assignment_unready'" do
        action.fetch(:spe_responses).each do |response|
          expect(given_assignment_uuids).to include response.fetch(:assignment_uuid)
          expect(response.fetch(:exercise_uuids)).to eq []
          expect(response.fetch(:assignment_status)).to eq 'assignment_unready'
        end
      end
    end
  end

  context "when previously-existing AssignmentSpe assignment_uuids are given" do
    let(:exercise_uuids_1)  do
      (given_max_num_exercises_1 + rand(given_max_num_exercises_1)).times.map { SecureRandom.uuid }
    end
    let!(:assignment_spe_1) do
      FactoryGirl.create :assignment_spe, assignment_uuid: given_assignment_uuid_1,
                                          exercise_uuids: exercise_uuids_1
    end
    let(:exercise_uuids_2)  do
      rand(given_max_num_exercises_2).times.map { SecureRandom.uuid }
    end
    let!(:assignment_spe_2) do
      FactoryGirl.create :assignment_spe, assignment_uuid: given_assignment_uuid_2,
                                          exercise_uuids: exercise_uuids_2
    end

    it "the assignment_uuids are returned with exercise_uuids and 'assignment_ready'" do
      assignment_spes = [ assignment_spe_1, assignment_spe_2 ]
      max_nums_exercises = [ given_max_num_exercises_1, given_max_num_exercises_2 ]

      action.fetch(:spe_responses).each_with_index do |response, index|
        assignment_spe = assignment_spes[index]
        max_num_exercises = max_nums_exercises[index]
        exercise_uuids = assignment_spe.exercise_uuids.first(max_num_exercises)

        expect(given_assignment_uuids).to include response.fetch(:assignment_uuid)
        expect(response.fetch(:exercise_uuids)).to eq exercise_uuids
        expect(response.fetch(:assignment_status)).to eq 'assignment_ready'
      end
    end
  end
end