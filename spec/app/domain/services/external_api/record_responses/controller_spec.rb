require 'rails_helper'

RSpec.describe ResponsesController, type: :request do
  let(:request_payload) { {responses: response_data} }

  let(:response_data) {
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
    }
  }

  let(:responses) {
    num_responses.times.map{
      response = build(:response)
    }
  }

  let(:num_responses) { 2 }

  let(:target_results) { [ SecureRandom.uuid.to_s, SecureRandom.uuid.to_s ] }

  let(:service_double) {
    dbl = object_double(Services::ExternalApi::RecordResponses.new)
    allow(dbl).to receive(:process)
              .with(response_data: response_data)
              .and_return(target_results)
    dbl
  }

  before(:each) do
    allow(Services::ExternalApi::RecordResponses).to receive(:new).and_return(service_double)
  end

  context "when a request is made" do
    it "the request and response payloads are validated against their schemas" do
      expect_any_instance_of(ResponsesController).to receive(:with_json_apis).and_call_original
      response_status, response_body = record_responses(request_payload: request_payload)
    end
    it "the response has status 200 (success)" do
      response_status, response_body = record_responses(request_payload: request_payload)
      expect(response_status).to eq(200)
    end
    it "the RecordResponses service is called with the correct Response data" do
      response_status, response_body = record_responses(request_payload: request_payload)
      expect(service_double).to have_received(:process)
    end
    it "the response contains the Response uuids returned by the RecordResponses service" do
      response_status, response_body = record_responses(request_payload: request_payload)
      expect(response_body.fetch('recorded_response_uuids')).to match_array(target_results)
    end
  end
end

def record_responses(request_payload:)
  make_post_request(
    route: '/record_responses',
    headers: { 'Content-Type' => 'application/json' },
    body:  request_payload.to_json
  )
  response_status  = response.status
  response_payload = JSON.parse(response.body)

  [response_status, response_payload]
end
