require 'rails_helper'

RSpec.describe 'trial response bundle scenarios' do

  context 'malformed request' do
    context 'number of requested bundles exceeds maximum', type: :request do
      before(:each) do
        @response_status, @response_payload = request_bundles(
          reader_number:             3,
          reader_modulo:             5,
          max_count:               101,
          confirmed_bundle_uuids:   [],
        )
      end
      let(:response_status)  { @response_status }
      let(:response_payload) { @response_payload }

      it 'returns status 400 (bad request)' do
        expect(response_status).to eq(400)
      end
      it 'returns appropriate error message(s)' do
        expect(response_payload['errors'].grep(/max_count/)).to_not be_empty
      end
    end
  end


  context 'no trial response bundles exist' do
    context 'request does not confirm any bundles', type: :request do
      before(:each) do
        @response_status, @response_payload = request_bundles(
          reader_number:             3,
          reader_modulo:             5,
          max_count:                10,
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
          reader_number:             3,
          reader_modulo:             5,
          max_count:                10,
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
    ## sent/unsent
    ## confirmed/unconfirmed
    ## open/closed
    ## multiple writer modulos
    ## multiple reader modulos
    context 'request does not confirm any bundles' do
      xit 'returns status 200 (success)'
      xit 'returns previously sent, unconfirmed bundles'
      xit 'returns previously unsent bundles'
      xit 'updates sent status closed bundles'
      xit 'does not update sent status of open bundles'
      xit 'prioritizes sending of closed bundles over open bundles'
      xit 'does not return previously confirmed, closed bundles'
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


def request_bundles(reader_number:, reader_modulo:, max_count:, confirmed_bundle_uuids:)
  request_payload = {
    'reader_number':          reader_number,
    'reader_modulo':          reader_modulo,
    'max_count':              max_count,
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
