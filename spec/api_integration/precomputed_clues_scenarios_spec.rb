require 'rails_helper'

describe 'precomputed CLUEs scenarios' do

  context 'retrieve precomputed CLUEs with invalid precompute CLUE uuid(s)', type: :request do
    before(:each) do
      @target_invalid_uuids = [ SecureRandom.uuid.to_s, SecureRandom.uuid.to_s ]
      @response_status, @response_payload = request_precomputed_clues(@target_invalid_uuids)
    end
    let(:target_invalid_uuids) { @target_invalid_uuids }
    let(:response_status)      { @response_status }
    let(:response_payload)     { @response_payload }

    it 'returns status 422 (unprocessable entity)' do
      expect(response_status).to eq(422)
    end
    it 'returns appropriate error message(s)' do
      target_invalid_uuids.each do |target_invalid_uuid|
        expect(response_payload['errors'].grep(/#{target_invalid_uuid}/)).to_not be_empty
      end
    end
  end

  context 'retrieve precomputed CLUEs with with valid precoputed CLUE uuid(s)', type: :request do
    before(:each) do
      ##
      ## Create learner uuids
      ##

      response_status, response_payload = create_learner_uuids(10)
      expect(response_status).to eq(200)
      expect(response_payload['learner_uuids'].count).to eq(10)

      learner_uuids = response_payload['learner_uuids']

      ##
      ## Create learner pool uuids
      ##

      learner_pool_defs = [ { 'learner_uuids': learner_uuids[0..5]  },
                            { 'learner_uuids': learner_uuids[6..-1] }, ]
      response_status, response_payload = create_learner_pools(learner_pool_defs)
      expect(response_status).to eq(200)
      expect(response_payload['learner_pool_uuids'].count).to eq(2)

      learner_pool_uuids = response_payload['learner_pool_uuids']

      ##
      ## Create question uuids
      ##

      response_status, response_payload = create_question_uuids(20)
      expect(response_status).to eq(200)
      expect(response_payload['question_uuids'].count).to eq(20)

      question_uuids = response_payload['question_uuids']

      ##
      ## Create question pool uuids
      ##

      question_pool_defs = [ { 'question_uuids': question_uuids[0..5]   },
                             { 'question_uuids': question_uuids[6..15]  },
                             { 'question_uuids': question_uuids[17..-1] }, ]
      response_status, response_payload = create_question_pools(question_pool_defs)
      expect(response_status).to eq(200)
      expect(response_payload['question_pool_uuids'].count).to eq(3)

      question_pool_uuids = response_payload['question_pool_uuids']

      ##
      ## Create precompute CLUE uuids
      ##

      precomputed_clue_defs = [ {'learner_pool_uuid':  learner_pool_uuids[0],
                                 'question_pool_uuid': question_pool_uuids[0] },
                                {'learner_pool_uuid':  learner_pool_uuids[0],
                                 'question_pool_uuid': question_pool_uuids[1] },
                                {'learner_pool_uuid':  learner_pool_uuids[0],
                                 'question_pool_uuid': question_pool_uuids[2] },
                                {'learner_pool_uuid':  learner_pool_uuids[1],
                                 'question_pool_uuid': question_pool_uuids[0] },
                                {'learner_pool_uuid':  learner_pool_uuids[1],
                                 'question_pool_uuid': question_pool_uuids[1] },
                                {'learner_pool_uuid':  learner_pool_uuids[1],
                                 'question_pool_uuid': question_pool_uuids[2] }, ]
      response_status, response_payload = create_precomputed_clues(precomputed_clue_defs)
      expect(response_status).to eq(200)
      expect(response_payload['precomputed_clue_uuids'].count).to eq(6)

      precomputed_clue_uuids = response_payload['precomputed_clue_uuids']

      ##
      ## Retrieve the precomputed CLUEs
      ##

      @target_precomputed_clue_uuids = precomputed_clue_uuids.values_at(1,4,5)
      @response_status, @response_payload = request_precomputed_clues(@target_precomputed_clue_uuids)
    end
    let(:target_precomputed_clue_uuids) { @target_precomputed_clue_uuids}
    let(:response_status)               { @response_status }
    let(:response_payload)              { @response_payload }

    it 'returns status 200 (success)' do
      expect(response_status).to eq(200)
    end

    it 'returns the appropriate number of precomputed CLUEs' do
      expect(response_payload['precomputed_clues'].count).to eq(target_precomputed_clue_uuids.count)
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


def request_precomputed_clues(precomputed_clue_uuids)
  request_payload = { 'precomputed_clue_uuids': precomputed_clue_uuids }

  make_post_request(
    route: '/retrieve_precomputed_clues',
    headers: { 'Content-Type' => 'application/json' },
    body:  request_payload.to_json
  )
  response_payload = JSON.parse(response.body)
  response_status = response.status

  [response_status, response_payload]
end


def create_question_uuids(count)
  request_payload = { 'count': count }

  make_post_request(
    route: '/create_questions',
    headers: { 'Content-Type' => 'application/json' },
    body:  request_payload.to_json
  )
  response_payload = JSON.parse(response.body)
  response_status = response.status

  [response_status, response_payload]
end


def create_question_pools(question_pool_defs)
  request_payload = { 'question_pool_defs': question_pool_defs }

  make_post_request(
    route: '/create_question_pools',
    headers: { 'Content-Type' => 'application/json' },
    body:  request_payload.to_json
  )
  response_payload = JSON.parse(response.body)
  response_status = response.status

  [response_status, response_payload]
end


def create_precomputed_clues(precomputed_clue_defs)
  request_payload = { 'precomputed_clue_defs': precomputed_clue_defs }

  make_post_request(
    route: '/create_precomputed_clues',
    headers: { 'Content-Type' => 'application/json' },
    body: request_payload.to_json
  )
  response_payload = JSON.parse(response.body)
  response_status = response.status

  [response_status, response_payload]
end
