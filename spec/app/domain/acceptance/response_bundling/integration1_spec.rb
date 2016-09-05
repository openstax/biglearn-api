require 'rails_helper'

RSpec.describe 'external API: /record_responses endpoint', type: :request do
  let(:request_payload) { {responses: given_response_data} }

  let(:given_response_data) {
    num_responses.times.map do
      response = build(:response)

      {
        response_uuid:  response.uuid,
        trial_uuid:     response.trial_uuid,
        trial_sequence: response.trial_sequence,
        learner_uuid:   response.learner_uuid,
        question_uuid:  response.question_uuid,
        is_correct:     response.is_correct,
        responded_at:   response.responded_at,
      }
    end
  }

  context "when the request contains Response data"  do
    let(:num_responses) { 10 }

    it "the response has status 200" do
      response_status, response_body = record_responses(request_payload: request_payload)
      expect(response_status).to eq(200)
    end
    it "the response has list of recorded Response uuids" do
      given_response_uuids = given_response_data.map{|data| data.fetch(:response_uuid)}

      response_status, response_body = record_responses(request_payload: request_payload)
      expect(response_body.fetch('recorded_response_uuids')).to match_array(given_response_uuids)
    end
    it "the correct number of Response records are created" do
      expect{
        record_responses(request_payload: request_payload)
      }.to change { Response.count }.by(num_responses)
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
