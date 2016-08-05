require 'rails_helper'

describe 'question-concept hint scenarios' do

  context 'creating question-concept hints using invalid question,concept uuids', type: :request do
    before(:each) do
      @invalid_question_uuids = 10.times.collect{ SecureRandom.uuid.to_s }
      @invalid_concept_uuids  = 20.times.collect{ SecureRandom.uuid.to_s }

      concept_uuid_groups = @invalid_concept_uuids.each_slice(2).collect{|x| x}
      question_concept_hint_defs = @invalid_question_uuids.zip(concept_uuid_groups).collect { |question_uuid, concept_uuids|
        { question_uuid: question_uuid,
          concept_uuids: concept_uuids }
      }

      @response_status, @response_payload = create_question_concept_hints(question_concept_hint_defs)
    end
    let(:invalid_question_uuids) { @invalid_question_uuids }
    let(:invalid_concept_uuids)  { @invalid_concept_uuids }
    let(:response_status)        { @response_status }
    let(:response_payload)       { @response_payload }

    it 'returns status 422 (unprocessable entity)' do
      expect(response_status).to eq(422)
    end
    it 'returns the appropriate error message(s)' do
      invalid_question_uuids.each do |uuid|
        expect(response_payload['errors'].grep(/#{uuid}/)).to_not be_empty
      end
      invalid_concept_uuids.each do |uuid|
        expect(response_payload['errors'].grep(/#{uuid}/)).to_not be_empty
      end
    end
  end

  context 'creating question-concept hints using valid question,concept uuids', type: :request do
    before(:each) do
      ##
      ## create concept uuids
      ##

      response_status, response_payload = create_concept_uuids(20)
      expect(response_status).to eq(200)
      expect(response_payload['concept_uuids'].count).to eq(20)

      concept_uuids = response_payload['concept_uuids']

      ##
      ## create question uuids
      ##

      response_status, response_payload = create_question_uuids(10)
      expect(response_status).to eq(200)
      expect(response_payload['question_uuids'].count).to eq(10)

      question_uuids = response_payload['question_uuids']

      ##
      ## create question-concept hints with valid question,concept uuids
      ##

      concept_uuid_groups = concept_uuids.each_slice(2).collect{|x| x}
      @question_concept_hint_defs = question_uuids.zip(concept_uuid_groups).collect { |question_uuid, concept_uuids|
        { question_uuid: question_uuid,
          concept_uuids: concept_uuids }
      }

      @response_status, @response_payload = create_question_concept_hints(@question_concept_hint_defs)
    end
    let(:question_concept_hint_defs) { @question_concept_hint_defs }
    let(:response_status)            { @response_status }
    let(:response_payload)           { @response_payload }

    it 'returns status 200 (success)' do
      expect(response_status).to eq(200)
    end
    it 'returns the number of created hints' do
      expect(response_payload['num_created_hints']).to eq(20)
    end
    it 'silently ignores duplicate hints' do
      response_status, response_payload = create_question_concept_hints(question_concept_hint_defs)
      expect(response_status).to eq(200)
      expect(response_payload['num_created_hints']).to eq(0)
    end
  end

end


def create_concept_uuids(count)
  request_payload = { 'count': count }

  make_post_request(
    route: '/create_concepts',
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


def create_question_concept_hints(question_concept_hint_defs)
  request_payload = { 'question_concept_hint_defs': question_concept_hint_defs}

  make_post_request(
    route: '/create_question_concept_hints',
    headers: { 'Content-Type' => 'application/json' },
    body: request_payload.to_json
  )
  response_payload = JSON.parse(response.body)
  response_status = response.status

  [response_status, response_payload]
end

