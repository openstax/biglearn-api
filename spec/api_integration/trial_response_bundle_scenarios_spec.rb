require 'rails_helper'

RSpec.describe 'trial response bundle scenarios' do

  context 'malformed request' do
    context 'number of requested bundles exceeds maximum', type: :request do
      before(:each) do
        @response_status, @response_payload = request_bundles(
          receiver_uuid:            SecureRandom.uuid.to_s,
          receiver_modulo:           3,
          receiver_count:            5,
          max_bundle_count:        101,
          confirmed_bundle_uuids:   [],
        )
      end
      let(:response_status)  { @response_status }
      let(:response_payload) { @response_payload }

      it 'returns status 400 (bad request)' do
        expect(response_status).to eq(400)
      end
      it 'returns appropriate error message(s)' do
        expect(response_payload['errors'].grep(/max_bundle_count/)).to_not be_empty
      end
    end
  end


  context 'no trial response bundles exist' do
    context 'request does not confirm any bundles', type: :request do
      before(:each) do
        @response_status, @response_payload = request_bundles(
          receiver_uuid:            SecureRandom.uuid.to_s,
          receiver_modulo:           3,
          receiver_count:            5,
          max_bundle_count:         10,
          confirmed_bundle_uuids:   [],
        )
      end
      let(:response_status)  { @response_status }
      let(:response_payload) { @response_payload }

      it 'returns status 200 (success)' do
        expect(response_status).to eq(200)
      end
      it 'returns a list of confirmed bundle uuids (none)' do
        expect(response_payload['confirmed_bundle_uuids']).to be_empty
      end
      it 'returns a list of ignored bundle uuids (none)' do
        expect(response_payload['ignored_bundle_uuids']).to be_empty
      end
      it 'returns a list of newly confirmed bundle uuids (none)' do
        expect(response_payload['newly_confirmed_bundle_uuids']).to be_empty
      end
      it 'returns no bundles' do
        expect(response_payload['bundles']).to be_empty
      end
    end
    context 'request confirms bundles', type: :request do
      before(:each) do
        @confirmed_bundle_uuids = 3.times.map{ SecureRandom.uuid.to_s }
        @response_status, @response_payload = request_bundles(
          receiver_uuid:            SecureRandom.uuid.to_s,
          receiver_modulo:          3,
          receiver_count:           5,
          max_bundle_count:         10,
          confirmed_bundle_uuids:   @confirmed_bundle_uuids,
        )
      end
      let(:confirmed_bundle_uuids) { @confirmed_bundle_uuids }
      let(:response_status)        { @response_status }
      let(:response_payload)       { @response_payload }

      it 'returns status 200 (success)' do
        expect(response_status).to eq(200)
      end
      it 'returns a list of confirmed bundle uuids (none)' do
        expect(response_payload['confirmed_bundle_uuids']).to be_empty
      end
      it 'returns a list of newly confirmed bundle uuids (none)' do
        expect(response_payload['newly_confirmed_bundle_uuids']).to be_empty
      end
      it 'returns a list of ignored bundle uuids' do
        expect(response_payload['ignored_bundle_uuids'].sort).to eq(confirmed_bundle_uuids.sort)
      end
    end
  end


  context 'trial response bundles exist' do
    let(:receiver_uuid)   { SecureRandom.uuid.to_s }
    let(:receiver_modulo) { 3 }
    let(:receiver_count)  { 5 }

    before(:each) do
      ##
      ## create a bundle:
      ##   - closed
      ##   - previously sent
      ##   - previously confirmed
      ##   - with appropriate reader modulo restriction
      ##
      @sent_conf_closed_bundle_uuid = create_bundle(
        is_open:                  false,
        uuid_modulo_restrictions: [[receiver_count, receiver_modulo, true]],
        num_trial_responses:      2,
      )

      create_bundle_receipt(
        bundle_uuid:             @sent_conf_closed_bundle_uuid,
        receiver_uuid:           receiver_uuid,
        is_previously_confirmed: true,
      )

      ##
      ## create a bundle:
      ##   - closed
      ##   - previously sent
      ##   - unconfirmed
      ##   - with appropriate reader modulo restriction
      ##
      @sent_unconf_closed_bundle_uuid = create_bundle(
        is_open:                  false,
        uuid_modulo_restrictions: [[receiver_count, receiver_modulo, true]],
        num_trial_responses:      2,
      )

      create_bundle_receipt(
        bundle_uuid:             @sent_unconf_closed_bundle_uuid,
        receiver_uuid:           receiver_uuid,
        is_previously_confirmed: false,
      )
    end
    let(:sent_conf_closed_bundle_uuid) { @sent_conf_closed_bundle_uuid }
    let(:sent_unconf_closed_bundle_uuid)    { @sent_unconf_closed_bundle_uuid }

    ## sent/unsent
    ## confirmed/unconfirmed
    ## open/closed
    ## multiple writer modulos
    ## multiple reader modulos
    context 'request does not confirm any bundles', type: :request do
      before(:each) do
        @response_status, @response_payload = request_bundles(
          receiver_uuid:            receiver_uuid,
          receiver_modulo:          receiver_modulo,
          receiver_count:           receiver_count,
          max_bundle_count:         10,
          confirmed_bundle_uuids:   [],
        )
      end
      let(:response_status)  { @response_status }
      let(:response_payload) { @response_payload }

      let(:returned_bundle_uuids) { response_payload['bundles'].map{|bundle| bundle['bundle_uuid']} }

      it 'returns status 200 (success)' do
        expect(response_status).to eq(200)
      end
      xit 'returns previously sent, unconfirmed bundles' do
        expect(returned_bundle_uuids).to include(sent_unconf_closed_bundle_uuid)
      end
      xit 'returns previously unsent bundles'
      xit 'updates sent status closed bundles'
      xit 'does not update sent status of open bundles'
      xit 'prioritizes sending of closed bundles over open bundles'
      it 'does not return previously confirmed, closed bundles' do
        expect(returned_bundle_uuids).to_not include(sent_conf_closed_bundle_uuid)
      end
      xit 'returns only bundles with appropriate reader modulo'
      xit 'returns a list of confirmed bundle uuids (none)'
      xit 'returns a list of ignored bundle uuids (none)'
    end
    context 'request does confirm bundles' do
      xit 'returns status 200 (success)'
      xit 'returns previously sent, unconfirmed bundles'
      xit 'returns previously unsent bundles'
      xit 'updates sent status closed bundles'
      xit 'does not update sent status of open bundles'
      xit 'updates confirm status of sent, closed bundles'
      xit 'does not update confirm status of open bundles'
      xit 'prioritizes sending of closed bundles over open bundles'
      xit 'does not return previously confirmed, closed bundles'
      xit 'does not return newly confirmed, closed bundles'
      xit 'returns only bundles with appropriate reader modulo'
      xit 'returns confirmed bundle uuids'
      xit 'returns a list of confirmed bundle uuids'
      xit 'returns a list of ignored bundle uuids'
    end
  end

end


def create_bundle(is_open:,
                  uuid_modulo_restrictions:,
                  num_trial_responses:)
  raise 'open bundles cannot be previously confirmed' \
    if is_open && is_previously_confirmed
  raise 'closed bundles must have at least one trial response' \
    if !is_open && num_trial_responses < 1

  bundle_uuid =
    loop do
      bundle_uuid = SecureRandom.uuid.to_s
      restriction_success = uuid_modulo_restrictions.all?{ |restriction|
        count, modulo, result = restriction
        restriction_met = (bundle_uuid.split('-').last.hex % count == modulo) == result
        restriction_met
      }
      break bundle_uuid if restriction_success
    end

  TrialResponseBundle.create!(
    uuid:    bundle_uuid,
    is_open: is_open,
  )

  num_trial_responses.times.map do
    response = TrialResponse.create!(
      response_uuid: SecureRandom.uuid.to_s,
      trial_uuid:    SecureRandom.uuid.to_s,
      learner_uuid:  SecureRandom.uuid.to_s,
      question_uuid: SecureRandom.uuid.to_s,
      is_correct:    ['true', 'false'].sample,
    )
    TrialResponseTrialResponseBundle.create!(
      trial_response_uuid:        response.response_uuid,
      trial_response_bundle_uuid: bundle_uuid,
    )
  end

  bundle_uuid
end


def create_bundle_receipt(bundle_uuid:,
                          receiver_uuid:,
                          is_previously_confirmed:)
  TrialResponseBundleReceipt.create!(
    trial_response_bundle_uuid: bundle_uuid,
    receiver_uuid:              receiver_uuid,
    is_confirmed:               is_previously_confirmed,
  )
end


def request_bundles(receiver_uuid:, receiver_count:, receiver_modulo:, max_bundle_count:, confirmed_bundle_uuids:)
  request_payload = {
    'receiver_uuid':          receiver_uuid,
    'receiver_count':         receiver_count,
    'receiver_modulo':        receiver_modulo,
    'max_bundle_count':       max_bundle_count,
    'confirmed_bundle_uuids': confirmed_bundle_uuids,
  }

  make_post_request(
    route: '/fetch_trial_response_bundles',
    headers: { 'Content-Type' => 'application/json' },
    body:  request_payload.to_json
  )
  response_payload = JSON.parse(response.body)
  response_status = response.status

  [response_status, response_payload]
end
