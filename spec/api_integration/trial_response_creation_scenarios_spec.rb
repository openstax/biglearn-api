require 'rails_helper'

RSpec.describe 'trial response creation scenarios' do

  context 'malformed request' do
    context 'number of trial responses exceeds maximum', type: :request do
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


  context 'request contain no trial responses', type: :request do
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

    it 'does not save any trial responses' do
      expect(final_response_count).to eq(initial_response_count)
    end
    it 'returns status 200 (success)' do
      expect(response_status).to eq(200)
    end
    it 'returns a list saved trial response uuids (none)' do
      expect(response_payload['saved_response_uuids']).to be_empty
    end
  end


  context 'request contains trial responses', type: :request do
    before(:each) do
      previously_saved_params = 3.times.map{
        {
          trial_uuid:    SecureRandom.uuid.to_s,
          response_uuid: SecureRandom.uuid.to_s,
          learner_uuid:  SecureRandom.uuid.to_s,
          question_uuid: SecureRandom.uuid.to_s,
          is_correct:    ['true', 'false'].sample,
        }
      }

      previously_saved_trial_responses = previously_saved_params.map do |params|
        TrialResponse.create!(params)
      end

      resaved_params = 3.times.map{
        {
          trial_uuid:    SecureRandom.uuid.to_s,
          response_uuid: SecureRandom.uuid.to_s,
          learner_uuid:  SecureRandom.uuid.to_s,
          question_uuid: SecureRandom.uuid.to_s,
          is_correct:    ['true', 'false'].sample,
        }
      }

      resaved_trial_responses = resaved_params.map do |params|
        TrialResponse.create!(params)
      end

      previously_unsaved_params = 3.times.map{
        {
          trial_uuid:    SecureRandom.uuid.to_s,
          response_uuid: SecureRandom.uuid.to_s,
          learner_uuid:  SecureRandom.uuid.to_s,
          question_uuid: SecureRandom.uuid.to_s,
          is_correct:    ['true', 'false'].sample,
        }
      }

      trial_responses = resaved_params + previously_unsaved_params
      response = record_responses(trial_responses)

      @previously_saved_params   = previously_saved_params
      @resaved_params            = resaved_params
      @previously_unsaved_params = previously_unsaved_params
      @response                  = response
    end
    let(:previously_saved_params)            { @previously_saved_params }
    let(:resaved_params)                     { @resaved_params }
    let(:previously_unsaved_params)          { @previously_unsaved_params }
    let(:response_status)                    { @response[0] }
    let(:response_payload)                   { @response[1] }

    it 'saves the new trial responses' do
      target_response_uuids = previously_unsaved_params.map{|params| params[:response_uuid]}
      newly_saved_response_uuids = TrialResponse.where{response_uuid.in target_response_uuids}.map(&:response_uuid)
      expect(newly_saved_response_uuids.sort).to eq(target_response_uuids.sort)
    end
    it 'returns status 200 (success)' do
      expect(response_status).to eq(200)
    end
    it 'returns a list of saved trial response uuids (saves are idempotent)' do
      target_response_uuids = (resaved_params + previously_unsaved_params).map{|params| params[:response_uuid]}
      expect(response_payload['saved_response_uuids'].sort).to eq(target_response_uuids.sort)
    end
    it 'returns a list of ignored (previously saved) trial response uuids' do
      target_response_uuids = resaved_params.map{|params| params[:response_uuid]}
      expect(response_payload['ignored_response_uuids'].sort).to eq(target_response_uuids.sort)
    end
    it 'returns newly-saved trial response uuids' do
      target_response_uuids = previously_unsaved_params.map{|params| params[:response_uuid]}
      expect(target_response_uuids - response_payload['newly_saved_response_uuids']).to be_empty
    end
    it 'does not return extraneous response uuids' do
      target_response_uuids = previously_saved_params.map{|params| params[:response_uuid]}
      expect(TrialResponse.where{response_uuid.in target_response_uuids}).to_not be_empty
      expect(target_response_uuids - response_payload['saved_response_uuids']).to eq(target_response_uuids)
    end
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
