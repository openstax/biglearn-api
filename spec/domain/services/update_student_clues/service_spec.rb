require 'rails_helper'

RSpec.describe Services::UpdateStudentClues::Service, type: :service do
  let(:service)                     { described_class.new }

  let(:given_algorithm_name)        { 'sparfa' }

  let(:given_request_uuid_1)        { SecureRandom.uuid }
  let(:given_calculation_uuid_1)    { SecureRandom.uuid }
  let(:given_student_uuid_1)        { SecureRandom.uuid }
  let(:given_book_container_uuid_1) { SecureRandom.uuid }
  let(:given_clue_data_1)           do
    {
      minimum: 0.7,
      most_likely: 0.8,
      maximum: 0.9,
      is_real: true,
      ecosystem_uuid: SecureRandom.uuid
    }
  end

  let(:given_request_uuid_2)        { SecureRandom.uuid }
  let(:given_calculation_uuid_2)    { SecureRandom.uuid }
  let(:given_student_uuid_2)        { SecureRandom.uuid }
  let(:given_book_container_uuid_2) { SecureRandom.uuid }
  let(:given_clue_data_2)           do
    {
      minimum: 0,
      most_likely: 0.5,
      maximum: 1,
      is_real: false
    }
  end

  let(:given_clue_updates)          do
    [
      {
        request_uuid: given_request_uuid_1,
        calculation_uuid: given_calculation_uuid_1,
        student_uuid: given_student_uuid_1,
        book_container_uuid: given_book_container_uuid_1,
        algorithm_name: given_algorithm_name,
        clue_data: given_clue_data_1
      },
      {
        request_uuid: given_request_uuid_2,
        calculation_uuid: given_calculation_uuid_2,
        student_uuid: given_student_uuid_2,
        book_container_uuid: given_book_container_uuid_2,
        algorithm_name: given_algorithm_name,
        clue_data: given_clue_data_2
      }
    ]
  end

  let(:action)                      do
    service.process(student_clue_updates: given_clue_updates)
  end

  let(:valid_request_uuids)         do
    [ given_request_uuid_1, given_request_uuid_2 ]
  end

  context "when the CLUe records do not yet exist" do
    it "new CLUe records are created with the correct attributes" do
      expect { action }.to change { StudentClue.count }.by(2)

      given_clue_updates.each do |update|
        student_clue = StudentClue.find_by uuid: update[:request_uuid]
        expect(student_clue.calculation_uuid).to eq update[:calculation_uuid]
        expect(student_clue.student_uuid).to eq update[:student_uuid]
        expect(student_clue.book_container_uuid).to eq update[:book_container_uuid]
        expect(student_clue.data.deep_symbolize_keys).to eq update[:clue_data]
      end

      action.fetch(:student_clue_update_responses).each_with_index do |response, index|
        expect(valid_request_uuids).to include(response[:request_uuid])
        expect(response[:update_status]).to eq 'accepted'
      end
    end
  end

  context "when the CLUe records already exist" do
    before do
      FactoryBot.create :student_clue, student_uuid: given_student_uuid_1,
                                        book_container_uuid: given_book_container_uuid_1,
                                        algorithm_name: given_algorithm_name
      FactoryBot.create :student_clue, student_uuid: given_student_uuid_2,
                                        book_container_uuid: given_book_container_uuid_2,
                                        algorithm_name: given_algorithm_name
    end

    it "existing CLUe records are updated with the correct attributes" do
      expect { action }.not_to change { StudentClue.count }

      given_clue_updates.each do |update|
        student_clue = StudentClue.find_by uuid: update[:request_uuid]
        expect(student_clue.calculation_uuid).to eq update[:calculation_uuid]
        expect(student_clue.student_uuid).to eq update[:student_uuid]
        expect(student_clue.book_container_uuid).to eq update[:book_container_uuid]
        expect(student_clue.data.deep_symbolize_keys).to eq update[:clue_data]
      end

      action.fetch(:student_clue_update_responses).each_with_index do |response, index|
        expect(valid_request_uuids).to include(response[:request_uuid])
        expect(response[:update_status]).to eq 'accepted'
      end
    end
  end
end
