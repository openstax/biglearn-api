require 'rails_helper'

describe 'learner-question response scenarios' do

  context 'creating learner-question responses using invalid learner,question uuids', type: :request do
    before(:each) do
      @invalid_learner_uuids  = 5.times.collect{ SecureRandom.uuid.to_s }
      @invalid_question_uuids = 3.times.collect{ SecureRandom.uuid.to_s }

      learner_question_response_defs = @invalid_learner_uuids.collect{ |invalid_learner_uuid|
        @invalid_question_uuids.collect{ |invalid_question_uuid|
          {
            learner_uuid:  invalid_learner_uuid,
            question_uuid: invalid_question_uuid,
            response:      ['correct', 'incorrect'].sample,
          }
        }
      }.flatten

      @response_status, @response_payload = create_learner_question_responses(learner_question_response_defs)
    end
    let(:invalid_learner_uuids)  { @invalid_learner_uuids }
    let(:invalid_question_uuids) { @invalid_question_uuids }
    let(:response_status)        { @response_status }
    let(:response_payload)       { @response_payload }

    it 'returns status 422 (unprocessable entity)' do
      expect(response_status).to eq(422)
    end
    it 'returns appropriate error message(s)' do
      invalid_question_uuids.each do |uuid|
        expect(response_payload['errors'].grep(/#{uuid}/)).to_not be_empty
      end
      invalid_learner_uuids.each do |uuid|
        expect(response_payload['errors'].grep(/#{uuid}/)).to_not be_empty
      end
    end
  end


  context 'creating learner-question responses using valid learner,question uuids', type: :request do
    before(:each) do
      ##
      ## create learner uuids
      ##

      response_status, response_payload = create_learner_uuids(5)
      expect(response_status).to eq(200)
      expect(response_payload['learner_uuids'].count).to eq(5)

      learner_uuids = response_payload['learner_uuids']


      ##
      ## create question uuids
      ##

      response_status, response_payload = create_question_uuids(3)
      expect(response_status).to eq(200)
      expect(response_payload['question_uuids'].count).to eq(3)

      question_uuids = response_payload['question_uuids']

      ##
      ## create learner-question responses
      ##

      learner_question_response_defs = learner_uuids.collect{ |learner_uuid|
        question_uuids.collect{ |question_uuid|
          {
            learner_uuid:  learner_uuid,
            question_uuid: question_uuid,
            response:      ['correct', 'incorrect'].sample,
          }
        }
      }.flatten

      @response_status, @response_payload = create_learner_question_responses(learner_question_response_defs)
    end
    let(:response_status)  { @response_status }
    let(:response_payload) { @response_payload }

    it 'returns status 200 (success)' do
      expect(response_status).to eq(200)
    end
    it 'returns the number of created responses' do
      expect(response_payload['num_created_responses']).to eq(15)
    end
  end
end

def create_learner_question_responses(learner_question_response_defs)
  request_payload = { 'learner_question_response_defs': learner_question_response_defs}

  make_post_request(
    route: '/create_learner_question_responses',
    headers: { 'Content-Type' => 'application/json' },
    body: request_payload.to_json
  )
  response_payload = JSON.parse(response.body)
  response_status = response.status

  [response_status, response_payload]
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
