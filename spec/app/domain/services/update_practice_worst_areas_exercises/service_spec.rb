require 'rails_helper'

RSpec.describe Services::UpdatePracticeWorstAreasExercises::Service, type: :service do
  let(:service)                     { described_class.new }

  let(:given_request_uuid_1)        { SecureRandom.uuid }
  let(:given_student_uuid_1)        { SecureRandom.uuid }
  let(:given_exercise_uuid_count_1) { rand(10) }

  let(:given_request_uuid_2)        { SecureRandom.uuid }
  let(:given_student_uuid_2)        { SecureRandom.uuid }
  let(:given_exercise_uuid_count_2) { rand(10) }

  let(:given_practice_worst_areas_updates)  do
    [
      {
        request_uuid:     given_request_uuid_1,
        student_uuid:     given_student_uuid_1,
        exercise_uuids:   given_exercise_uuid_count_1.times.map{ SecureRandom.uuid }
      },
      {
        request_uuid:     given_request_uuid_2,
        student_uuid:     given_student_uuid_2,
        exercise_uuids:   given_exercise_uuid_count_2.times.map{ SecureRandom.uuid }
      }
    ]
  end

  let(:action)                      do
    service.process(practice_worst_areas_updates: given_practice_worst_areas_updates)
  end

  let(:valid_request_uuids)         do
    [ given_request_uuid_1, given_request_uuid_2 ]
  end

  context "when the student pe records do not yet exist" do
    it "new student pe records are created with the correct attributes" do
      expect{action}.to change{StudentPe.count}.by(2)

      given_practice_worst_areas_updates.each do |update|
        student_pe = StudentPe.find_by uuid: update[:request_uuid]
        expect(student_pe.student_uuid).to eq update[:student_uuid]
        expect(student_pe.exercise_uuids).to eq update[:exercise_uuids]
      end

      action.fetch(:practice_worst_areas_update_responses).each_with_index do |response, index|
        expect(valid_request_uuids).to include(response[:request_uuid])
        expect(response[:update_status]).to eq 'accepted'
      end
    end
  end

  context "when the student pe records already exist" do
    before do
      FactoryGirl.create :student_pe, student_uuid: given_student_uuid_1
      FactoryGirl.create :student_pe, student_uuid: given_student_uuid_2
    end

    it "existing student pe records are updated with the correct attributes" do
      expect{action}.not_to change{StudentPe.count}

      given_practice_worst_areas_updates.each do |update|
        student_pe = StudentPe.find_by uuid: update[:request_uuid]
        expect(student_pe.student_uuid).to eq update[:student_uuid]
        expect(student_pe.exercise_uuids).to eq update[:exercise_uuids]
      end

      action.fetch(:practice_worst_areas_update_responses).each_with_index do |response, index|
        expect(valid_request_uuids).to include(response[:request_uuid])
        expect(response[:update_status]).to eq 'accepted'
      end
    end
  end
end