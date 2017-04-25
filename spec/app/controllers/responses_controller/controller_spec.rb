require 'rails_helper'

RSpec.describe ResponsesController, type: :request do
  let(:given_response_uuid)   { SecureRandom.uuid }
  let(:given_course_uuid)     { SecureRandom.uuid }
  let(:given_sequence_number) { rand(10) }
  let(:given_ecosystem_uuid)  { SecureRandom.uuid }
  let(:given_trial_uuid)      { SecureRandom.uuid }
  let(:given_student_uuid)    { SecureRandom.uuid }
  let(:given_exercise_uuid)   { SecureRandom.uuid }
  let(:given_is_correct)      { [true, false].sample }
  let(:given_responded_at)    { Time.now.utc.iso8601(6) }

  let(:given_responses)       do
    [
      {
        response_uuid: given_response_uuid,
        course_uuid: given_course_uuid,
        sequence_number: given_sequence_number,
        ecosystem_uuid: given_ecosystem_uuid,
        trial_uuid: given_trial_uuid,
        student_uuid: given_student_uuid,
        exercise_uuid: given_exercise_uuid,
        is_correct: given_is_correct,
        responded_at: given_responded_at
      }
    ]
  end

  let(:request_payload)                    { { responses: given_responses } }

  let(:target_result)                      do
    { recorded_response_uuids: given_responses.map { |response| response.fetch(:response_uuid) } }
  end
  let(:target_response)                    { target_result }

  let(:service_double)                     do
    object_double(Services::RecordResponses::Service.new).tap do |dbl|
      allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
    end
  end

  before(:each)                            do
    allow(Services::RecordResponses::Service).to receive(:new).and_return(service_double)
  end

  context "when a valid request is made" do
    it "the request and response payloads are validated against their schemas" do
      expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
      response_status, response_body = record_responses(request_payload: request_payload)
    end

    it "the response has status 200 (success)" do
      response_status, response_body = record_responses(request_payload: request_payload)
      expect(response_status).to eq(200)
    end

    it "the RecordResponses service is called with the correct response data" do
      response_status, response_body = record_responses(request_payload: request_payload)
      expect(service_double).to have_received(:process)
    end

    it "the response contains the target_response" do
      response_status, response_body = record_responses(request_payload: request_payload)
      expect(response_body).to eq(target_response.deep_stringify_keys)
    end
  end

  protected

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
end
