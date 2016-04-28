require 'rails_helper'

describe 'learner pool scenarios' do
  context 'creating learner pool using invalid learner uuids' do
    it 'returns 422 (unprocessable entity) with appropriate error messages(s)', type: :request do
      invalid_learner_uuids = 10.times.collect{ SecureRandom.uuid.to_s }
      learner_pool_defs = [ { learner_uuids: invalid_learner_uuids[0..5]  },
                            { learner_uuids: invalid_learner_uuids[6..-1] } ]

      response_status, response_payload = create_learner_pools(learner_pool_defs)

      expect(response_status).to eq(422)
      invalid_learner_uuids.each do |uuid|
        expect(response_payload['errors'].grep(/#{uuid}/)).to_not be_empty
      end
    end
  end

  context 'creating learner pool using valid learner uuids' do
    it 'returns 200 (success) with appropriate number of learner uuids', type: :request do
      ##
      ## Create learner uuids
      ##

      response_status, response_payload = create_learner_uuids(5)
      expect(response_status).to eq(200)
      expect(response_payload['learner_uuids'].count).to eq(5)

      learner_uuids = response_payload['learner_uuids']

      ##
      ## Create learner pool uuids
      ##

      learner_pool_defs = [ { learner_uuids: learner_uuids[0..3] },
                            { learner_uuids: learner_uuids[3..4] } ]

      response_status, response_payload = create_learner_pools(learner_pool_defs)

      expect(response_status).to eq(200)
      expect(response_payload['learner_pool_uuids'].count).to eq(2)
    end
  end
end

def create_learner_uuids(count)
  request_payload = { 'count': count }

  make_post_request(
    route: '/create_learners',
    headers: { 'Content-Type' => 'application/json' },
    body:  request_payload.to_json
  )
  response_payload = JSON.parse(response.body)
  response_status = response.status

  [response_status, response_payload]
end


def create_learner_pools(learner_pool_defs)
  request_payload = { 'learner_pool_defs': learner_pool_defs }

  make_post_request(
    route: '/create_learner_pools',
    headers: { 'Content-Type' => 'application/json' },
    body:  request_payload.to_json
  )
  response_payload = JSON.parse(response.body)
  response_status = response.status

  [response_status, response_payload]
end
