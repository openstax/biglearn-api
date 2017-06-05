require 'rails_helper'

RSpec.describe Services::UpdateAssignmentSpes::Service, type: :service do
  let(:service)                     { described_class.new }

  let(:given_algorithm_name)        { 'tesr_instructor_driven' }

  let(:given_request_uuid_1)        { SecureRandom.uuid }
  let(:given_assignment_uuid_1)     { SecureRandom.uuid }
  let(:given_exercise_uuid_count_1) { rand(10) }
  let(:given_spy_info_1)            { { test: true } }

  let(:given_request_uuid_2)        { SecureRandom.uuid }
  let(:given_assignment_uuid_2)     { SecureRandom.uuid }
  let(:given_exercise_uuid_count_2) { rand(10) }
  let(:given_spy_info_2)            { { another_test: true } }

  let(:given_spe_updates)  do
    [
      {
        request_uuid: given_request_uuid_1,
        assignment_uuid: given_assignment_uuid_1,
        algorithm_name: given_algorithm_name,
        exercise_uuids: given_exercise_uuid_count_1.times.map{ SecureRandom.uuid },
        spy_info: given_spy_info_1
      },
      {
        request_uuid: given_request_uuid_2,
        assignment_uuid: given_assignment_uuid_2,
        algorithm_name: given_algorithm_name,
        exercise_uuids: given_exercise_uuid_count_2.times.map{ SecureRandom.uuid },
        spy_info: given_spy_info_2
      }
    ]
  end

  let(:action)                      do
    service.process(spe_updates: given_spe_updates)
  end

  let(:valid_request_uuids)         do
    [ given_request_uuid_1, given_request_uuid_2 ]
  end

  context "when the assignment spe records do not yet exist" do
    it "new assignment spe records are created with the correct attributes" do
      expect{action}.to change{AssignmentSpe.count}.by(2)

      given_spe_updates.each do |update|
        assignment_spe = AssignmentSpe.find_by uuid: update[:request_uuid]
        expect(assignment_spe.assignment_uuid).to eq update[:assignment_uuid]
        expect(assignment_spe.exercise_uuids).to eq update[:exercise_uuids]
        expect(assignment_spe.spy_info).to eq update[:spy_info].deep_stringify_keys
      end

      action.fetch(:spe_update_responses).each_with_index do |response, index|
        expect(valid_request_uuids).to include(response[:request_uuid])
        expect(response[:update_status]).to eq 'accepted'
      end
    end
  end

  context "when the assignment spe records already exist" do
    before do
      FactoryGirl.create :assignment_spe, assignment_uuid: given_assignment_uuid_1,
                                          algorithm_name: given_algorithm_name
      FactoryGirl.create :assignment_spe, assignment_uuid: given_assignment_uuid_2,
                                          algorithm_name: given_algorithm_name
    end

    it "existing assignment spe records are updated with the correct attributes" do
      expect{action}.not_to change{AssignmentSpe.count}

      given_spe_updates.each do |update|
        assignment_spe = AssignmentSpe.find_by uuid: update[:request_uuid]
        expect(assignment_spe.assignment_uuid).to eq update[:assignment_uuid]
        expect(assignment_spe.exercise_uuids).to eq update[:exercise_uuids]
        expect(assignment_spe.spy_info).to eq update[:spy_info].deep_stringify_keys
      end

      action.fetch(:spe_update_responses).each_with_index do |response, index|
        expect(valid_request_uuids).to include(response[:request_uuid])
        expect(response[:update_status]).to eq 'accepted'
      end
    end
  end
end
