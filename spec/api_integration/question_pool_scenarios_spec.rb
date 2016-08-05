require 'rails_helper'

describe 'question pool scenarios' do
  context 'creating question pool using invalid question uuids', type: :request do
    before(:each) do
      @invalid_question_uuids = 10.times.collect{ SecureRandom.uuid.to_s }
      question_pool_defs = [ { question_uuids: @invalid_question_uuids[0..5]  },
                            { question_uuids: @invalid_question_uuids[6..-1] } ]

      @response_status, @response_payload = create_question_pools(question_pool_defs)
    end
    let(:invalid_question_uuids) { @invalid_question_uuids }
    let(:response_status)        { @response_status }
    let(:response_payload)       { @response_payload }

    it 'returns status 422 (unprocessable entity)' do
      expect(response_status).to eq(422)
    end
    it 'returns the appropriate error messages(s)' do
      invalid_question_uuids.each do |uuid|
        expect(response_payload['errors'].grep(/#{uuid}/)).to_not be_empty
      end
    end
  end

  context 'creating question pool using valid question uuids', type: :request do
    before(:each) do
      ##
      ## Create question uuids
      ##

      response_status, response_payload = create_question_uuids(5)
      expect(response_status).to eq(200)
      expect(response_payload['question_uuids'].count).to eq(5)

      question_uuids = response_payload['question_uuids']

      ##
      ## Create question pool uuids
      ##

      question_pool_defs = [ { question_uuids: question_uuids[0..3] },
                            { question_uuids: question_uuids[3..4] } ]

      @response_status, @response_payload = create_question_pools(question_pool_defs)
    end
    let(:response_status)  { @response_status }
    let(:response_payload) { @response_payload }

    it 'returns status 200 (success)' do
      expect(response_status).to eq(200)
    end
    it 'returns the appropriate number of question uuids' do
      expect(response_payload['question_pool_uuids'].count).to eq(2)
    end
  end
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
