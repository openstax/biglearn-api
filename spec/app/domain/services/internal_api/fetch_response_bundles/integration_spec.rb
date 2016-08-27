require 'rails_helper'

RSpec.describe 'internal API: /fetch_response_bundles endpoint' do
  let(:request_payload) {
    {
      max_bundles_to_return:  given_max_bundles_to_return,
      confirmed_bundle_uuids: given_bundle_uuids_to_confirm,
      receiver_info: {
        receiver_uuid:    given_receiver_uuid,
        partition_count:  given_partition_count,
        partition_modulo: given_partition_modulo,
      },
    }
  }

  let(:given_max_bundles_to_return)    { 0 }
  let(:given_bundle_uuids_to_confirm)  { [] }
  let(:given_receiver_uuid)            { SecureRandom.uuid.to_s }
  let(:given_partition_count)          { 6 }
  let(:given_partition_modulo)         { 2 }

  let(:target_receiver_uuid)       { SecureRandom.uuid.to_s }
  let(:target_partition_count)     { 1 }
  let(:target_partition_modulo)    { 0 }

  let!(:responses) {
    10.times.map do
      create(:response)
    end
  }

  let!(:bundle_responses) {
    responses.take(8).map do |response|
      create(:bundle_response, for_response: response)
    end
  }

  let!(:bundle_response_bundles) {
    bundle_responses.each_slice(2).take(3).map do |brs|
      create(:bundle_response_bundle, for_bundle_responses: brs)
    end
  }

  let!(:bundle_response_confirmations) {
    bundle_response_bundles.take(1).map do |brb|
      create(:bundle_response_confirmation, receiver_uuid: target_receiver_uuid, for_bundle: brb)
    end
  }

  context "when the setup is complicated", type: :request do
    let(:given_max_bundles_to_return)   { 2 }
    let(:given_receiver_uuid)           { target_receiver_uuid }
    let(:given_partition_count)         { target_partition_count }
    let(:given_partition_modulo)        { target_partition_modulo }
    let(:given_bundle_uuids_to_confirm) { [] }

    it "returns the expected values" do
      response_status, response_payload = fetch_response_bundles(request_payload: request_payload)

      target_responses    = responses.values_at(*(2..5).to_a).sort_by{|response| response.uuid}
      target_bundle_uuids = bundle_response_bundles.values_at(1,2).map(&:uuid)

      aggregate_failures "value checks" do
        expect(response_status).to eq(200)
        expect(response_payload.fetch('confirmed_bundle_uuids')).to be_empty
        expect(response_payload.fetch('bundle_uuids')).to match_array(target_bundle_uuids)

        expect(target_responses).to_not be_empty
        expect(response_payload.fetch('responses').count).to eq(target_responses.count)
        returned_response_data = response_payload.fetch('responses').sort_by{|data| data.fetch('response_uuid')}
        returned_response_data.zip(target_responses).each do |response_data, target_response|
          expect(target_response.uuid).to           eq(response_data.fetch('response_uuid'))
          expect(target_response.trial_uuid).to     eq(response_data.fetch('trial_uuid'))
          expect(target_response.trial_sequence).to eq(response_data.fetch('trial_sequence'))
          expect(target_response.learner_uuid).to   eq(response_data.fetch('learner_uuid'))
          expect(target_response.question_uuid).to  eq(response_data.fetch('question_uuid'))
          expect(target_response.is_correct).to     eq(response_data.fetch('is_correct'))
          expect(target_response.responded_at).to   eq(Chronic.parse(response_data.fetch('responded_at')))
        end
      end
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
