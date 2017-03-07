require 'rails_helper'

RSpec.describe Services::UpdateTeacherClues::Service, type: :service do
  let(:service)                       { described_class.new }

  let(:given_algorithm_name)          { 'SPARFA' }

  let(:given_request_1_uuid)          { SecureRandom.uuid }
  let(:given_course_container_1_uuid) { SecureRandom.uuid }
  let(:given_book_container_1_uuid)   { SecureRandom.uuid }
  let(:given_clue_data_1)             do
    {
      minimum: 0.7,
      most_likely: 0.8,
      maximum: 0.9,
      is_real: true,
      ecosystem_uuid: SecureRandom.uuid
    }
  end

  let(:given_request_2_uuid)          { SecureRandom.uuid }
  let(:given_course_container_2_uuid) { SecureRandom.uuid }
  let(:given_book_container_2_uuid)   { SecureRandom.uuid }
  let(:given_clue_data_2)             do
    {
      minimum: 0,
      most_likely: 0.5,
      maximum: 1,
      is_real: false
    }
  end

  let(:given_clue_updates)            do
    [
      {
        request_uuid: given_request_1_uuid,
        course_container_uuid: given_course_container_1_uuid,
        book_container_uuid: given_book_container_1_uuid,
        algorithm_name: given_algorithm_name,
        clue_data: given_clue_data_1
      },
      {
        request_uuid: given_request_2_uuid,
        course_container_uuid: given_course_container_2_uuid,
        book_container_uuid: given_book_container_2_uuid,
        algorithm_name: given_algorithm_name,
        clue_data: given_clue_data_2
      }
    ]
  end

  let(:action)                        do
    service.process(teacher_clue_updates: given_clue_updates)
  end

  let(:valid_request_uuids)           do
    [ given_request_1_uuid, given_request_2_uuid ]
  end

  context "when the CLUe records do not yet exist" do
    it "new CLUe records are created with the correct attributes" do
      expect{action}.to change{TeacherClue.count}.by(2)

      given_clue_updates.each do |update|
        teacher_clue = TeacherClue.find_by uuid: update[:request_uuid]
        expect(teacher_clue.course_container_uuid).to eq update[:course_container_uuid]
        expect(teacher_clue.book_container_uuid).to eq update[:book_container_uuid]
        expect(teacher_clue.data.deep_symbolize_keys).to eq update[:clue_data]
      end

      action.fetch(:teacher_clue_update_responses).each_with_index do |response, index|
        expect(valid_request_uuids).to include(response[:request_uuid])
        expect(response[:update_status]).to eq 'accepted'
      end
    end
  end

  context "when the CLUe records already exist" do
    before do
      FactoryGirl.create :teacher_clue, course_container_uuid: given_course_container_1_uuid,
                                        book_container_uuid: given_book_container_1_uuid,
                                        algorithm_name: given_algorithm_name
      FactoryGirl.create :teacher_clue, course_container_uuid: given_course_container_2_uuid,
                                        book_container_uuid: given_book_container_2_uuid,
                                        algorithm_name: given_algorithm_name
    end

    it "existing CLUe records are updated with the correct attributes" do
      expect{action}.not_to change{TeacherClue.count}

      given_clue_updates.each do |update|
        teacher_clue = TeacherClue.find_by uuid: update[:request_uuid]
        expect(teacher_clue.course_container_uuid).to eq update[:course_container_uuid]
        expect(teacher_clue.book_container_uuid).to eq update[:book_container_uuid]
        expect(teacher_clue.data.deep_symbolize_keys).to eq update[:clue_data]
      end

      action.fetch(:teacher_clue_update_responses).each_with_index do |response, index|
        expect(valid_request_uuids).to include(response[:request_uuid])
        expect(response[:update_status]).to eq 'accepted'
      end
    end
  end
end
