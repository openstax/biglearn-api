require 'rails_helper'

RSpec.describe GlobalExerciseExclusionsController, type: :request do
  let(:request_payload) do
    {
      request_uuid:    given_request_uuid,
      sequence_number: given_sequence_number,
      exclusions:      given_exclusions
    }
  end

  let(:given_exclusions) do
    (given_specific_version_exclusions + given_any_version_exclusions).shuffle
  end

  let(:given_specific_version_exclusions) do
    number_of_exclusions.times.map { { exercise_uuid: SecureRandom.uuid } }
  end

  let(:given_any_version_exclusions) do
    number_of_exclusions.times.map { { exercise_group_uuid: SecureRandom.uuid } }
  end

  let(:given_request_uuid)    { SecureRandom.uuid }
  let(:given_sequence_number) { rand(10) }
  let(:number_of_exclusions)  { 10 }

  let(:target_result)         { { status: 'success' } }

  let(:service_double)        do
    object_double(Services::UpdateGlobalExerciseExclusions::Service.new).tap do |dbl|
      allow(dbl).to receive(:process)
                .with(
                  request_uuid:    given_request_uuid,
                  sequence_number: given_sequence_number,
                  exclusions:      given_exclusions
                )
                .and_return(target_result)
    end
  end

  before(:each) do
    allow(Services::UpdateGlobalExerciseExclusions::Service).to(
      receive(:new).and_return(service_double)
    )
  end

  context "when a valid request is made" do
    it "the request and response payloads are validated against their schemas" do
      expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
      response_status, response_body = update_globally_excluded_exercises(
        request_payload: request_payload
      )
    end
    it "the response has status 200 (success)" do
      response_status, response_body = update_globally_excluded_exercises(
        request_payload: request_payload
      )
      expect(response_status).to eq(200)
    end
    it "the UpdateGlobalExerciseExclusions service is called with the correct exclusions data" do
      response_status, response_body = update_globally_excluded_exercises(
        request_payload: request_payload
      )
      expect(service_double).to have_received(:process)
    end
    it "the response contains the status" do
      response_status, response_body = update_globally_excluded_exercises(
        request_payload: request_payload
      )
      expect(response_body.fetch('status')).to eq('success')
    end
  end
end

def update_globally_excluded_exercises(request_payload:)
  make_post_request(
    route: '/update_globally_excluded_exercises',
    headers: { 'Content-Type' => 'application/json' },
    body:  request_payload.to_json
  )
  response_status  = response.status
  response_payload = JSON.parse(response.body)

  [response_status, response_payload]
end
