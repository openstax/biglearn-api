require 'rails_helper'

RSpec.describe 'new learner response scenarios' do

  context 'malformed request' do
    context 'number of learner responses exceeds maximum', type: :request do
      before(:each) do
        responses = 1001.times.map{
          {
            trial_uuid:    SecureRandom.uuid.to_s,
            response_uuid: SecureRandom.uuid.to_s,
            learner_uuid:  SecureRandom.uuid.to_s,
            question_uuid: SecureRandom.uuid.to_s,
            is_correct:    ['true', 'false'].sample,
          }
        }
        @response_status, @response_payload = record_responses(responses)
      end
      let(:response_status)  { @response_status }
      let(:response_payload) { @response_payload }

      it 'returns status 400 (bad request)' do
        expect(response_status).to eq(400)
      end
      it 'returns appropriate error message(s)' do
        expect(response_payload['errors'].grep(/responses.*allowed/)).to_not be_empty
      end
    end
  end


  context 'no learner responses', type: :request do
    before(:each) do
      @initial_response_count = TrialResponse.count
      responses = []
      @response_status, @response_payload = record_responses(responses)
      @final_response_count = TrialResponse.count
    end
    let(:initial_response_count) { @initial_response_count }
    let(:final_response_count)   { @final_response_count }
    let(:response_status)        { @response_status }
    let(:response_payload)       { @response_payload }

    it 'does not save any learner responses' do
      expect(final_response_count).to eq(initial_response_count)
    end
    it 'returns status 200 (success)' do
      expect(response_status).to eq(200)
    end
    it 'returns a list saved learner response uuids (none)' do
      expect(response_payload['saved_response_uuids']).to be_empty
    end
  end


  context 'learner responses' do
    ## previously saved/unsaved
    ## valud/invalid
    xit 'saves the new learner responses'
    xit 'returns status 200 (success)'
    xit 'returns a list of saved learner response uuids'
    xit 'returns a list of not-saved learner response uuids'
    xit 'returns re-saved learner response uuids (saves are idempotent)'
  end

end


def record_responses(responses)
  request_payload = {
    'responses': responses,
  }

  make_post_request(
    route: '/record_trial_responses',
    headers: { 'Content-Type' => 'application/json' },
    body:  request_payload.to_json
  )
  response_payload = JSON.parse(response.body)
  response_status = response.status

  [response_status, response_payload]
end
