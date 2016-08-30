require 'rails_helper'

RSpec.describe Services::ExternalApi::RecordResponses do
  let(:service) { Services::ExternalApi::RecordResponses.new }

  let(:action) { service.process(response_data: given_response_data) }

  context "when no response data is given" do
    let(:given_response_data) { [] }

    let!(:split_time) { time = Time.now; sleep(0.001); time }

    it "no Responses are created" do
      expect{action}.to_not change{Response.count}
    end
    it "no Responses are updated" do
      action

      updated_responses = Response.where{updated_at > my{split_time}}
      expect(updated_responses).to be_empty
    end
    it "an empty uuid array is returned" do
      expect(action).to be_empty
    end
  end

  context "when response data is given" do
    let!(:responses) {
      [ create(:response), build(:response), create(:response), build(:response) ]
    }

    let(:existing_responses) { responses.values_at(0, 2) }
    let(:new_responses)      { responses.values_at(1, 3) }

    let(:given_response_data) {
      responses.map{ |response|
        {
          response_uuid:  response.uuid,
          trial_uuid:     response.trial_uuid,
          trial_sequence: response.trial_sequence,
          learner_uuid:   response.learner_uuid,
          question_uuid:  response.question_uuid,
          is_correct:     response.is_correct,
          responded_at:   response.responded_at.utc.iso8601(6),
        }
      } * 2
    }

    let!(:split_time) { time = Time.now; sleep(0.001); time }

    it "Responses are created for only previously-unseen response data" do
      action

      target_response_uuids = new_responses.map(&:uuid)
      newly_created_responses = Response.where{created_at > my{split_time}}

      expect(newly_created_responses.map(&:uuid)).to match_array(target_response_uuids)
    end
    it "Responses for previously-seen response data are left unchanged" do
      action

      target_response_uuids = existing_responses.map(&:uuid)
      updated_target_responses = Response.where{updated_at > my{split_time}}
                                         .where{uuid.in target_response_uuids}

      expect(updated_target_responses).to be_empty
    end
    it "all unique given Response uuids are returned (idempotence)" do
      target_uuids = given_response_data.map{|data| data.fetch(:response_uuid)}.uniq
      expect(action).to match_array(target_uuids)
    end
    it 'the newly-created Response records have the correct parameters' do
      action

      newly_created_responses = Response.where{created_at > my{split_time}}

      given_response_data_by_response_uuid = given_response_data.inject({}){ |result, given_response_data|
        result[given_response_data.fetch(:response_uuid)] = given_response_data
        result
      }

      newly_created_responses.each do |newly_created_response|
        given_response_data = given_response_data_by_response_uuid[newly_created_response.uuid]
        aggregate_failures 'response param checks' do
          expect(newly_created_response.uuid).to           eq(given_response_data[:response_uuid])
          expect(newly_created_response.trial_uuid).to     eq(given_response_data[:trial_uuid])
          expect(newly_created_response.trial_sequence).to eq(given_response_data[:trial_sequence])
          expect(newly_created_response.learner_uuid).to   eq(given_response_data[:learner_uuid])
          expect(newly_created_response.question_uuid).to  eq(given_response_data[:question_uuid])
          expect(newly_created_response.is_correct).to     eq(given_response_data[:is_correct])
          expect(newly_created_response.responded_at).to   eq(Chronic.parse(given_response_data[:responded_at]))
        end
      end
    end
  end
end
