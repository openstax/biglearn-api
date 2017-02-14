require 'rails_helper'

RSpec.describe Services::UpdateStudentClues::Service, type: :service do
  let(:service)                     { described_class.new }

  let(:given_request_1_uuid)        { SecureRandom.uuid }
  let(:given_student_1_uuid)        { SecureRandom.uuid }
  let(:given_book_container_1_uuid) { SecureRandom.uuid }
  let(:given_clue_data_1)           do
    {
      aggregate: 0.8,
      confidence: {
        left: 0.7,
        right: 0.9,
        sample_size: 10,
        unique_learner_count: 1
      },
      interpretation: {
        confidence: 'good',
        level: 'high',
        threshold: 'above'
      },
      pool_id: given_book_container_1_uuid
    }
  end

  let(:given_request_2_uuid)        { SecureRandom.uuid }
  let(:given_student_2_uuid)        { SecureRandom.uuid }
  let(:given_book_container_2_uuid) { SecureRandom.uuid }
  let(:given_clue_data_2)           do
    {
      aggregate: 0.5,
      confidence: {
        left: 0,
        right: 1,
        sample_size: 0,
        unique_learner_count: 0
      },
      interpretation: {
        confidence: 'bad',
        level: 'low',
        threshold: 'below'
      },
      pool_id: given_book_container_2_uuid
    }
  end

  let(:given_clue_updates)          do
    [
      {
        request_uuid: given_request_1_uuid,
        student_uuid: given_student_1_uuid,
        book_container_uuid: given_book_container_1_uuid,
        clue_data: given_clue_data_1
      },
      {
        request_uuid: given_request_2_uuid,
        student_uuid: given_student_2_uuid,
        book_container_uuid: given_book_container_2_uuid,
        clue_data: given_clue_data_2
      }
    ]
  end

  let(:action)                      do
    service.process(student_clue_updates: given_clue_updates)
  end

  let(:valid_request_uuids)         do
    [ given_request_1_uuid, given_request_2_uuid ]
  end

  context "when the CLUe records do not yet exist" do
    it "new CLUe records are created with the correct attributes" do
      expect{action}.to change{StudentClue.count}.by(2)

      given_clue_updates.each do |update|
        student_clue = StudentClue.find_by uuid: update[:request_uuid]
        expect(student_clue.student_uuid).to eq update[:student_uuid]
        expect(student_clue.book_container_uuid).to eq update[:book_container_uuid]

        clue_data = update[:clue_data]
        expect(student_clue.aggregate).to eq clue_data[:aggregate]

        confidence = clue_data[:confidence]
        expect(student_clue.confidence_left).to eq confidence[:left]
        expect(student_clue.confidence_right).to eq confidence[:right]
        expect(student_clue.sample_size).to eq confidence[:sample_size]

        interpretation = clue_data[:interpretation]
        expect(student_clue.is_good_confidence).to eq(interpretation[:confidence] == 'good')
        expect(student_clue.is_high_level).to eq(interpretation[:level] == 'high')
        expect(student_clue.is_above_threshold).to eq(interpretation[:threshold] == 'above')
      end

      action.fetch(:student_clue_update_responses).each_with_index do |response, index|
        expect(valid_request_uuids).to include(response[:request_uuid])
        expect(response[:update_status]).to eq 'accepted'
      end
    end
  end

  context "when the CLUe records already exist" do
    before do
      FactoryGirl.create :student_clue, student_uuid: given_student_1_uuid,
                                        book_container_uuid: given_book_container_1_uuid
      FactoryGirl.create :student_clue, student_uuid: given_student_2_uuid,
                                        book_container_uuid: given_book_container_2_uuid
    end

    it "existing CLUe records are updated with the correct attributes" do
      expect{action}.not_to change{StudentClue.count}

      given_clue_updates.each do |update|
        student_clue = StudentClue.find_by uuid: update[:request_uuid]
        expect(student_clue.student_uuid).to eq update[:student_uuid]
        expect(student_clue.book_container_uuid).to eq update[:book_container_uuid]

        clue_data = update[:clue_data]
        expect(student_clue.aggregate).to eq clue_data[:aggregate]

        confidence = clue_data[:confidence]
        expect(student_clue.confidence_left).to eq confidence[:left]
        expect(student_clue.confidence_right).to eq confidence[:right]
        expect(student_clue.sample_size).to eq confidence[:sample_size]

        interpretation = clue_data[:interpretation]
        expect(student_clue.is_good_confidence).to eq(interpretation[:confidence] == 'good')
        expect(student_clue.is_high_level).to eq(interpretation[:level] == 'high')
        expect(student_clue.is_above_threshold).to eq(interpretation[:threshold] == 'above')
      end

      action.fetch(:student_clue_update_responses).each_with_index do |response, index|
        expect(valid_request_uuids).to include(response[:request_uuid])
        expect(response[:update_status]).to eq 'accepted'
      end
    end
  end
end
