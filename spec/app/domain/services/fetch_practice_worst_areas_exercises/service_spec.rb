require 'rails_helper'

RSpec.describe Services::FetchPracticeWorstAreasExercises::Service, type: :service do
  let(:service)                    { described_class.new }

  let(:given_algorithm_name)       { 'tesr' }

  let(:given_request_uuid_1)       { SecureRandom.uuid }
  let(:given_student_uuid_1)       { SecureRandom.uuid }
  let(:given_max_num_exercises_1)  { rand(10) }
  let(:given_request_uuid_2)       { SecureRandom.uuid }
  let(:given_student_uuid_2)       { SecureRandom.uuid }

  let(:given_worst_areas_requests) do
    [
      {
        request_uuid: given_request_uuid_1,
        student_uuid: given_student_uuid_1,
        algorithm_name: given_algorithm_name,
        max_num_exercises: given_max_num_exercises_1
      },
      {
        request_uuid: given_request_uuid_2,
        student_uuid: given_student_uuid_2,
        algorithm_name: given_algorithm_name
      }
    ]
  end

  let(:action)                     do
    service.process(worst_areas_requests: given_worst_areas_requests)
  end

  let(:requests_by_request_uuid)   do
    given_worst_areas_requests.index_by { |req| req[:request_uuid] }
  end

  context "when non-existing StudentPe student_uuids and algorithm_names are given" do
    context "when non-existing Student uuids are given" do
      it "the student_uuids are returned with student_status: 'student_unknown'" do
        action.fetch(:worst_areas_responses).each do |response|
          request = requests_by_request_uuid.fetch(response.fetch(:request_uuid))
          expect(response.fetch(:student_uuid)).to eq request.fetch(:student_uuid)
          expect(response.fetch(:exercise_uuids)).to eq []
          expect(response.fetch(:student_status)).to eq 'student_unknown'
        end
      end
    end

    context "when previously-existing Student uuids are given" do
      before do
        [ given_student_uuid_1, given_student_uuid_2 ].each do |student_uuid|
          FactoryGirl.create :student, uuid: student_uuid
        end
      end

      it "the student_uuids are returned with student_status: 'student_unready'" do
        action.fetch(:worst_areas_responses).each do |response|
          request = requests_by_request_uuid.fetch(response.fetch(:request_uuid))
          expect(response.fetch(:student_uuid)).to eq request.fetch(:student_uuid)
          expect(response.fetch(:exercise_uuids)).to eq []
          expect(response.fetch(:student_status)).to eq 'student_unready'
        end
      end
    end
  end

  context "when previously-existing StudentPe student_uuids and algorithm_names are given" do
    let(:exercise_uuids_1) do
      (given_max_num_exercises_1 + rand(given_max_num_exercises_1 + 1)).times.map do
        SecureRandom.uuid
      end
    end
    let!(:student_pe_1) do
      FactoryGirl.create :student_pe, student_uuid: given_student_uuid_1,
                                      algorithm_name: given_algorithm_name,
                                      exercise_uuids: exercise_uuids_1
    end
    let(:exercise_uuids_2) do
      rand(10).times.map { SecureRandom.uuid }
    end
    let!(:student_pe_2) do
      FactoryGirl.create :student_pe, student_uuid: given_student_uuid_2,
                                      algorithm_name: given_algorithm_name,
                                      exercise_uuids: exercise_uuids_2
    end

    it "the student_uuids are returned" +
       " with the requested number of exercise_uuids and 'student_ready'" do
      action.fetch(:worst_areas_responses).each_with_index do |response, index|
        request = requests_by_request_uuid.fetch(response.fetch(:request_uuid))
        student_uuid = request.fetch(:student_uuid)
        student_pe = StudentPe.find_by student_uuid: student_uuid
        all_exercise_uuids = student_pe.exercise_uuids
        max_num_exercises = request[:max_num_exercises]
        exercise_uuids = max_num_exercises.nil? ?
                           all_exercise_uuids : all_exercise_uuids.first(max_num_exercises)

        expect(response.fetch(:student_uuid)).to eq student_uuid
        expect(response.fetch(:exercise_uuids)).to eq exercise_uuids
        expect(response.fetch(:student_status)).to eq 'student_ready'
      end
    end
  end
end
