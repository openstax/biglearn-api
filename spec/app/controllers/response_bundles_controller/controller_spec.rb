require 'rails_helper'

RSpec.describe ResponseBundlesController, type: :request do
  let(:request_payload) {
    {
      max_bundles_to_return:  max_bundles_to_return,
      confirmed_bundle_uuids: bundle_uuids_to_confirm,
      receiver_info: {
        receiver_uuid:    target_receiver_uuid,
        partition_count:  partition_count,
        partition_modulo: target_partition_modulo,
      },
    }
  }

  let(:max_bundles_to_return)   { 0 }
  let(:bundle_uuids_to_confirm) { [] }
  let(:target_receiver_uuid)    { SecureRandom.uuid.to_s }

  let(:partition_count)            { 5 }
  let(:target_partition_modulo)    { 3 }

  let(:responses) { [ build(:response), build(:response) ] }

  let(:target_response_data) {
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

  let(:target_bundle_uuids) { [ SecureRandom.uuid.to_s, SecureRandom.uuid.to_s ] }

  let(:target_confirmed_bundle_uuids) { [ SecureRandom.uuid.to_s, SecureRandom.uuid.to_s ] }

  let(:target_results) {
    {
      response_data:          target_response_data,
      bundle_uuids:           target_bundle_uuids,
      confirmed_bundle_uuids: target_confirmed_bundle_uuids,
    }
  }

  let(:service_double) {
    dbl = object_double(Services::FetchResponseBundles::Service.new)
    allow(dbl).to receive(:process)
              .with(
                max_bundles_to_return:   max_bundles_to_return,
                bundle_uuids_to_confirm: bundle_uuids_to_confirm,
                receiver_uuid:           target_receiver_uuid,
                partition_count:         partition_count,
                partition_modulo:        target_partition_modulo,
              ).and_return(target_results)
    dbl
  }

  before(:each) do
    allow(Services::FetchResponseBundles::Service).to receive(:new).and_return(service_double)
  end

  context "when a request is made" do
    it "the request and response payloads are validated against their schemas" do
      expect_any_instance_of(ResponseBundlesController).to receive(:with_json_apis).and_call_original
      response_status, response_body = fetch_response_bundles(request_payload: request_payload)
    end
    it "the response has status 200 (success)" do
      response_status, response_body = fetch_response_bundles(request_payload: request_payload)
      expect(response_status).to eq(200)
    end
    it "the FetchResponseBundles service is called with the correct request data" do
      response_status, response_body = fetch_response_bundles(request_payload: request_payload)
      expect(service_double).to have_received(:process)
    end
    it "the response contains the Response data returned by the FetchResponseBundles service" do
      response_status, response_body = fetch_response_bundles(request_payload: request_payload)

      aggregate_failures "Response data checks" do
        returned_response_data = response_body.fetch('responses')
        expect(returned_response_data).to_not be_empty
        expect(returned_response_data.count).to eq(target_response_data.count)
        returned_response_data.zip(target_response_data).each do |(returned_data, target_data)|
          expect(returned_data.fetch('response_uuid')).to  eq(target_data.fetch(:response_uuid))
          expect(returned_data.fetch('trial_uuid')).to     eq(target_data.fetch(:trial_uuid))
          expect(returned_data.fetch('trial_sequence')).to eq(target_data.fetch(:trial_sequence))
          expect(returned_data.fetch('learner_uuid')).to   eq(target_data.fetch(:learner_uuid))
          expect(returned_data.fetch('question_uuid')).to  eq(target_data.fetch(:question_uuid))
          expect(returned_data.fetch('is_correct')).to     eq(target_data.fetch(:is_correct))
          expect(returned_data.fetch('responded_at')).to   eq(target_data.fetch(:responded_at))
        end
      end
    end
    it "the response contains the bundle uuids returned by the FetchResponseBundles service" do
      response_status, response_body = fetch_response_bundles(request_payload: request_payload)
      expect(response_body.fetch('bundle_uuids')).to match_array(target_bundle_uuids)
    end
    it "the response contains the confirmed bundle uuids returned by the FetchResponseBundles service" do
      response_status, response_body = fetch_response_bundles(request_payload: request_payload)
      expect(response_body.fetch('confirmed_bundle_uuids')).to match_array(target_confirmed_bundle_uuids)
    end
  end
end

def fetch_response_bundles(request_payload:)
  make_post_request(
    route: '/fetch_response_bundles',
    headers: { 'Content-Type' => 'application/json' },
    body:  request_payload.to_json
  )
  response_status  = response.status
  response_payload = JSON.parse(response.body)

  [response_status, response_payload]
end
