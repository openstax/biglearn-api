require 'rails_helper'

RSpec.describe Services::FetchAssignmentPes::Service, type: :service do
  let(:service)                   { described_class.new }

  let(:given_algorithm_name)      { 'biglearn_sparfa' }

  let(:given_request_uuid_1)      { SecureRandom.uuid }
  let(:given_assignment_uuid_1)   { SecureRandom.uuid }
  let(:given_max_num_exercises_1) { rand(10) }
  let(:given_request_uuid_2)      { SecureRandom.uuid }
  let(:given_assignment_uuid_2)   { SecureRandom.uuid }

  let(:given_pe_requests)         do
    [
      {
        request_uuid: given_request_uuid_1,
        assignment_uuid: given_assignment_uuid_1,
        algorithm_name: given_algorithm_name,
        max_num_exercises: given_max_num_exercises_1
      },
      {
        request_uuid: given_request_uuid_2,
        assignment_uuid: given_assignment_uuid_2,
        algorithm_name: given_algorithm_name
      }
    ]
  end

  let(:action)                    { service.process(pe_requests: given_pe_requests) }

  let(:requests_by_request_uuid)  { given_pe_requests.index_by { |req| req[:request_uuid] } }

  context "when non-existing AssignmentPe assignment_uuids and algorithm_names are given" do
    context "when non-existing Assignment uuids are given" do
      it "the assignment_uuids are returned with assignment_status: 'assignment_unknown'" do
        action.fetch(:pe_responses).each do |response|
          request = requests_by_request_uuid.fetch(response.fetch(:request_uuid))
          expect(response.fetch(:calculation_uuid)).to be_nil
          expect(response.fetch(:ecosystem_matrix_uuid)).to be_nil
          expect(response.fetch(:assignment_uuid)).to eq request.fetch(:assignment_uuid)
          expect(response.fetch(:exercise_uuids)).to eq []
          expect(response.fetch(:assignment_status)).to eq 'assignment_unknown'
        end
      end
    end

    context "when previously-existing Assignment uuids are given" do
      before do
        [ given_assignment_uuid_1, given_assignment_uuid_2 ].each do |assignment_uuid|
          FactoryBot.create :assignment, uuid: assignment_uuid
        end
      end

      it "the assignment_uuids are returned with assignment_status: 'assignment_unready'" do
        action.fetch(:pe_responses).each do |response|
          request = requests_by_request_uuid.fetch(response.fetch(:request_uuid))
          expect(response.fetch(:calculation_uuid)).to be_nil
          expect(response.fetch(:ecosystem_matrix_uuid)).to be_nil
          expect(response.fetch(:assignment_uuid)).to eq request.fetch(:assignment_uuid)
          expect(response.fetch(:exercise_uuids)).to eq []
          expect(response.fetch(:assignment_status)).to eq 'assignment_unready'
        end
      end
    end
  end

  context "when previously-existing AssignmentPe assignment_uuids and algorithm_names are given" do
    let(:exercise_uuids_1) do
      (given_max_num_exercises_1 + rand(given_max_num_exercises_1 + 1)).times.map do
        SecureRandom.uuid
      end
    end
    let!(:assignment_pe_1) do
      FactoryBot.create :assignment_pe, assignment_uuid: given_assignment_uuid_1,
                                         algorithm_name: given_algorithm_name,
                                         exercise_uuids: exercise_uuids_1
    end
    let(:exercise_uuids_2) do
      rand(10).times.map { SecureRandom.uuid }
    end
    let!(:assignment_pe_2) do
      FactoryBot.create :assignment_pe, assignment_uuid: given_assignment_uuid_2,
                                         algorithm_name: given_algorithm_name,
                                         exercise_uuids: exercise_uuids_2
    end

    it "the assignment_uuids are returned" +
       " with the requested number of exercise_uuids and 'assignment_ready'" do
      action.fetch(:pe_responses).each_with_index do |response, index|
        request = requests_by_request_uuid.fetch(response.fetch(:request_uuid))
        assignment_uuid = request.fetch(:assignment_uuid)
        assignment_pe = AssignmentPe.find_by assignment_uuid: assignment_uuid
        all_exercise_uuids = assignment_pe.exercise_uuids
        max_num_exercises = request[:max_num_exercises]
        exercise_uuids = max_num_exercises.nil? ?
                           all_exercise_uuids : all_exercise_uuids.first(max_num_exercises)
        spy_info = assignment_pe.spy_info

        expect(response.fetch(:calculation_uuid)).to be_a(String)
        expect(response.fetch(:ecosystem_matrix_uuid)).to be_a(String)
        expect(response.fetch(:assignment_uuid)).to eq assignment_uuid
        expect(response.fetch(:exercise_uuids)).to eq exercise_uuids
        expect(response.fetch(:assignment_status)).to eq 'assignment_ready'
        expect(response.fetch(:spy_info)).to eq spy_info
      end
    end
  end
end
