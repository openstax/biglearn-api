require 'rails_helper'

RSpec.describe Services::RecordResponses::Service do
  let(:service) { described_class.new }

  let(:action)  { service.process(responses: given_responses) }

  context "when no response data is given" do
    let(:given_responses) { [] }

    it "no CourseEvents are created" do
      expect{action}.to_not change{CourseEvent.count}
    end

    it "an empty uuid array is returned" do
      expect(action.fetch(:recorded_response_uuids)).to be_empty
    end
  end

  context "when response data is given" do
    let(:given_response_data) do
      4.times.map do
        {
          response_uuid:  SecureRandom.uuid,
          course_uuid:    SecureRandom.uuid,
          sequence_number: rand(1000),
          ecosystem_uuid: SecureRandom.uuid,
          trial_uuid:     SecureRandom.uuid,
          student_uuid:   SecureRandom.uuid,
          exercise_uuid:  SecureRandom.uuid,
          is_correct:     [true, false].sample,
          responded_at:   Time.current.iso8601(6)
        }
      end
    end

    let(:existing_response_data) { given_response_data.values_at(0, 2) }
    let(:new_response_data)      { given_response_data.values_at(1, 3) }

    let(:given_responses)        { given_response_data * 2 }

    let!(:existing_responses)    do
      existing_response_data.map do |response_data|
        FactoryGirl.create :course_event,
                           uuid: response_data.fetch(:response_uuid),
                           type: :record_response,
                           course_uuid: response_data.fetch(:course_uuid),
                           sequence_number: response_data.fetch(:sequence_number),
                           data: response_data.slice(
                             :response_uuid,
                             :sequence_number,
                             :ecosystem_uuid,
                             :trial_uuid,
                             :student_uuid,
                             :exercise_uuid,
                             :is_correct,
                             :responded_at
                           )
      end
    end

    it "CourseEvents are created for only previously-unseen response data" do
      expect{action}.to change{CourseEvent.count}.by(new_response_data.size)

      target_response_uuids = new_response_data.map{ |data| data.fetch(:response_uuid) }
      newly_created_responses = CourseEvent.where(uuid: target_response_uuids)
      expect(newly_created_responses.size).to eq(new_response_data.size)
    end

    it "CourseEvents for previously-seen response data are left unchanged" do
      target_response_uuids = existing_response_data.map{ |data| data.fetch(:response_uuid) }
      expect(existing_responses.size).to eq(existing_response_data.size)
      target_updated_ats = existing_responses.map{ |response| response.reload.updated_at }

      expect{action}.to change{CourseEvent.count}.by(new_response_data.size)

      existing_responses.each do |response|
        response.reload

        expect(target_response_uuids).to include response.uuid
        expect(target_updated_ats).to include response.updated_at
      end
    end

    it "all unique given response_uuids are returned (idempotence)" do
      target_uuids = given_response_data.map{ |data| data.fetch(:response_uuid) }.uniq
      expect(action.fetch(:recorded_response_uuids)).to match_array(target_uuids)
    end

    it 'the newly-created CourseEvent records have the correct parameters' do
      expect{action}.to change{CourseEvent.count}.by(new_response_data.size)

      new_response_uuids = new_response_data.map{ |data| data.fetch(:response_uuid) }
      newly_created_responses = CourseEvent.where(uuid: new_response_uuids)

      given_response_data_by_response_uuid = given_response_data.index_by do |response|
        response.fetch(:response_uuid)
      end

      newly_created_responses.each do |newly_created_response|
        given_response_data = given_response_data_by_response_uuid[newly_created_response.uuid]

        aggregate_failures 'record_response data checks' do
          expect(newly_created_response.uuid).to eq(given_response_data.fetch(:response_uuid))
          expect(newly_created_response.course_uuid).to eq(given_response_data.fetch(:course_uuid))
          expect(newly_created_response.sequence_number).to(
            eq(given_response_data.fetch(:sequence_number))
          )

          data = newly_created_response.data.deep_symbolize_keys
          expect(data.fetch(:ecosystem_uuid)).to eq(given_response_data.fetch(:ecosystem_uuid))
          expect(data.fetch(:trial_uuid)).to eq(given_response_data.fetch(:trial_uuid))
          expect(data.fetch(:student_uuid)).to eq(given_response_data.fetch(:student_uuid))
          expect(data.fetch(:exercise_uuid)).to eq(given_response_data.fetch(:exercise_uuid))
          expect(data.fetch(:is_correct)).to eq(given_response_data.fetch(:is_correct))
          expect(DateTime.parse(data.fetch(:responded_at))).to(
            be_within(1e-6).of(DateTime.parse(given_response_data.fetch(:responded_at)))
          )
        end
      end
    end
  end
end
