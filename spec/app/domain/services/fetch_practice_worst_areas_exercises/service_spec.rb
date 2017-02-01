require 'rails_helper'

RSpec.describe Services::FetchPracticeWorstAreasExercises::Service, type: :service do
  let(:service)                    { described_class.new }

  let(:given_student_uuid_1)       { SecureRandom.uuid }
  let(:given_max_num_exercises_1)  { rand(10) }
  let(:given_student_uuid_2)       { SecureRandom.uuid }
  let(:given_max_num_exercises_2)  { rand(10) }

  let(:given_worst_areas_requests) do
    [
      { student_uuid: given_student_uuid_1, max_num_exercises: given_max_num_exercises_1 },
      { student_uuid: given_student_uuid_2, max_num_exercises: given_max_num_exercises_2 }
    ]
  end

  let(:action)                     do
    service.process(worst_areas_requests: given_worst_areas_requests)
  end

  let(:given_student_uuids)    { [ given_student_uuid_1, given_student_uuid_2 ] }

  context "when non-existing StudentPe student_uuids are given" do
    context "when non-existing Student uuids are given" do
      it "the student_uuids are returned with student_status: 'student_unknown'" do
        action.fetch(:worst_areas_responses).each do |response|
          expect(given_student_uuids).to include response.fetch(:student_uuid)
          expect(response.fetch(:exercise_uuids)).to eq []
          expect(response.fetch(:student_status)).to eq 'student_unknown'
        end
      end
    end

    context "when previously-existing Student uuids are given" do
      before do
        given_student_uuids.each do |student_uuid|
          FactoryGirl.create :student, uuid: student_uuid
        end
      end

      it "the student_uuids are returned with assignment_status: 'student_unready'" do
        action.fetch(:worst_areas_responses).each do |response|
          expect(given_student_uuids).to include response.fetch(:student_uuid)
          expect(response.fetch(:exercise_uuids)).to eq []
          expect(response.fetch(:student_status)).to eq 'student_unready'
        end
      end
    end
  end

  context "when previously-existing StudentPe student_uuids are given" do
    let(:exercise_uuids_1) do
      (given_max_num_exercises_1 + rand(given_max_num_exercises_1 + 1)).times.map do
        SecureRandom.uuid
      end
    end
    let!(:student_pe_1)    do
      FactoryGirl.create :student_pe, student_uuid: given_student_uuid_1,
                                      exercise_uuids: exercise_uuids_1
    end
    let(:exercise_uuids_2) do
      rand(given_max_num_exercises_2 + 1).times.map { SecureRandom.uuid }
    end
    let!(:student_pe_2)    do
      FactoryGirl.create :student_pe, student_uuid: given_student_uuid_2,
                                      exercise_uuids: exercise_uuids_2
    end

    it "the student_uuids are returned with exercise_uuids and student_status: 'student_ready'" do
      student_pes = [ student_pe_1, student_pe_2 ]
      max_nums_exercises = [ given_max_num_exercises_1, given_max_num_exercises_2 ]

      action.fetch(:worst_areas_responses).each_with_index do |response, index|
        student_pe = student_pes[index]
        max_num_exercises = max_nums_exercises[index]
        exercise_uuids = student_pe.exercise_uuids.first(max_num_exercises)

        expect(given_student_uuids).to include response.fetch(:student_uuid)
        expect(response.fetch(:exercise_uuids)).to eq exercise_uuids
        expect(response.fetch(:student_status)).to eq 'student_ready'
      end
    end
  end
end
