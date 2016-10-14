require 'rails_helper'

RSpec.describe GlobalExerciseExclusionsController, type: :request do
  let(:request_payload) { 
    {
      sequence_number:    given_sequence_number,
      exclusions:         given_exclusions,
      request_uuid:       given_request_uuid
    }
  }

  let(:given_exclusions) {
    (given_specific_version_exclusions + given_any_version_exclusions).shuffle
  }

  let(:given_specific_version_exclusions) {
    (number_of_exclusions - given_any_version_exclusions.length).times.map{
      { 'exercise_uuid' => SecureRandom.uuid.to_s }
    }
  }

  let(:given_any_version_exclusions) {
    Kernel::rand(number_of_exclusions).times.map{
      { 'exercise_group_uuid' => SecureRandom.uuid.to_s }
    }
  }

  let(:given_request_uuid)    { SecureRandom.uuid.to_s }
  let(:given_sequence_number) { Kernel::rand(10) }
  let(:number_of_exclusions)  { 10 }

  let(:target_result)         { { status: 'success' } }

  let(:service_double) {
    dbl = object_double(Services::UpdateGlobalExerciseExclusions::Service.new)
    allow(dbl).to receive(:process)
              .with(
                update_uuid:        given_request_uuid,
                sequence_number:    given_sequence_number,
                exclusions:         given_exclusions,
              )
              .and_return(target_result)
    dbl
  }

  before(:each) do
    allow(Services::UpdateGlobalExerciseExclusions::Service).to receive(:new).and_return(service_double)
  end

  context "when a valid request is made" do
    it "the request and response payloads are validated against their schemas" do
      expect_any_instance_of(GlobalExerciseExclusionsController).to receive(:with_json_apis).and_call_original
      response_status, response_body = update_globally_excluded_exercises(request_payload: request_payload)
    end
    it "the response has status 200 (success)" do
      response_status, response_body = update_globally_excluded_exercises(request_payload: request_payload)
      expect(response_status).to eq(200)
    end
    it "the UpdateGlobalExerciseExclusions service is called with the correct exclusions data" do
      response_status, response_body = update_globally_excluded_exercises(request_payload: request_payload)
      expect(service_double).to have_received(:process)
    end
    it "the response contains the status" do
      response_status, response_body = update_globally_excluded_exercises(request_payload: request_payload)
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