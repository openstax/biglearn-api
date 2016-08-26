require 'rails_helper'

RSpec.describe 'external API: /record_responses endpoint' do
  let(:request_payload) { {responses: response_data} }

  let(:response_data) {
    num_responses.times.map do
      response = build(:response)

      {
        response_uuid:  response.uuid,
        trial_uuid:     response.trial_uuid,
        trial_sequence: response.trial_sequence,
        learner_uuid:   response.learner_uuid,
        question_uuid:  response.question_uuid,
        is_correct:     response.is_correct,
        responded_at:   response.responded_at,
      }
    end
  }

  context 'malformed request', type: :request do

    context '"responses" field is missing' do
      let(:request_payload) { {} }

      it 'response has status 400' do
        response_status, response_body = record_responses(request_payload: request_payload)
        expect(response_status).to eq(400)
      end
      it 'response has appropriate error message(s)' do
        response_status, response_body = record_responses(request_payload: request_payload)
        expect(response_body['errors'].grep(/did not contain.*responses/)).to_not be_empty
      end
      it 'no Response records are created' do
        expect{
          record_responses(request_payload: request_payload)
        }.to_not change { Response.count }
      end
    end

    context 'number of responses exceeds maximum allowed' do
      let(:num_responses) { 1001 }

      it 'response has status 400 and the appropriate error messages' do
        response_status, response_body = record_responses(request_payload: request_payload)
        aggregate_failures 'response checks' do
          expect(response_status).to eq(400)
          expect(response_body['errors'].grep(/responses.*allowed/)).to_not be_empty
        end
      end
    end

  end


  context 'valid request', type: :request do

    let(:all_response_uuids) { response_data.map{|response_data| response_data[:response_uuid]} }

    context 'request contains no responses' do
      let(:num_responses) { 0 }

      it 'response has status 200' do
        response_status, response_body = record_responses(request_payload: request_payload)
        expect(response_status).to eq(200)
      end
      it 'response has [empty] list of recorded response uuids' do
        response_status, response_body = record_responses(request_payload: request_payload)
        expect(response_body['recorded_response_uuids']).to be_empty
      end
      it 'no Response records are created' do
        expect{
          record_responses(request_payload: request_payload)
        }.to_not change { Response.count }
      end
    end


    context 'request contains responses' do
      let(:num_responses) { 10 }

      it 'response has status 200' do
        response_status, response_body = record_responses(request_payload: request_payload)
        expect(response_status).to eq(200)
      end
      it 'response has list of recorded response uuids' do
        response_status, response_body = record_responses(request_payload: request_payload)
        expect(response_body.fetch('recorded_response_uuids').sort).to eq(all_response_uuids.sort)
      end
      it 'the correct number of Response records are created' do
        expect{
          record_responses(request_payload: request_payload)
        }.to change { Response.count }.by(num_responses)
      end
      it 'the created Response records have the correct parameters' do
        record_responses(request_payload: request_payload)

        recorded_responses = Response.find_each.to_a
        response_data_by_response_uuid = response_data.inject({}){ |result, response_data|
          result[response_data.fetch(:response_uuid)] = response_data
          result
        }
        recorded_responses.each do |recorded_response|
          target_response_data = response_data_by_response_uuid[recorded_response.uuid]
          aggregate_failures 'response param checks' do
            expect(recorded_response.uuid).to           eq(target_response_data[:response_uuid])
            expect(recorded_response.trial_uuid).to     eq(target_response_data[:trial_uuid])
            expect(recorded_response.trial_sequence).to eq(target_response_data[:trial_sequence])
            expect(recorded_response.learner_uuid).to   eq(target_response_data[:learner_uuid])
            expect(recorded_response.question_uuid).to  eq(target_response_data[:question_uuid])
            expect(recorded_response.is_correct).to     eq(target_response_data[:is_correct])
            expect((recorded_response.responded_at - target_response_data[:responded_at]).abs).to be <= 001.second
          end
        end
      end
    end


    context 'request contains maximum number of responses' do
      let(:num_responses) { 1000 }

      it 'response has status 200 and the correct recorded response uuids' do
        response_status, response_body = record_responses(request_payload: request_payload)
        aggregate_failures 'response checks' do
          expect(response_status).to eq(200)
          expect(response_body['recorded_response_uuids'].sort).to eq(all_response_uuids.sort)
        end
      end
    end


    context 'request contains previously-recorded responses' do
      let(:num_responses) { 50 }

      let!(:previously_recorded_response_uuids) {
        response_data.sample(10).map do |response_data|
          response = create(:response,
            uuid:            response_data.fetch(:response_uuid),
            trial_uuid:      response_data.fetch(:trial_uuid),
            trial_sequence:  response_data.fetch(:trial_sequence),
            learner_uuid:    response_data.fetch(:learner_uuid),
            question_uuid:   response_data.fetch(:question_uuid),
            is_correct:      response_data.fetch(:is_correct),
            responded_at:    response_data.fetch(:responded_at),
          )
          response.uuid
        end
      }

      let(:newly_recorded_response_uuids) { all_response_uuids - previously_recorded_response_uuids }

      it 'response has status 200' do
        response_status, response_body = record_responses(request_payload: request_payload)
        expect(response_status).to eq(200)
      end
      it 'response has list of recorded response uuids (including previously-recorded response uuids)' do
        response_status, response_body = record_responses(request_payload: request_payload)
        expect(response_body['recorded_response_uuids'].sort).to eq(all_response_uuids.sort)
      end
      it 'creates Response records for only the new responses' do
        split_time = Time.now
        sleep(0.002)

        expect {
          record_responses(request_payload: request_payload)
        }.to change{ Response.count }.by(40)
        target_response_uuids = Response.where{created_at > split_time}.map(&:uuid).to_a

        expect(target_response_uuids.sort).to eq(newly_recorded_response_uuids.sort)
      end
      it 'does not alter previously-recorded Response records' do
        split_time = Time.now
        sleep(0.002)

        record_responses(request_payload: request_payload)
        target_response_updated_times = Response.where{created_at < split_time}.map(&:updated_at).to_a

        expect(target_response_updated_times.count).to eq(10)
        expect(target_response_updated_times.max).to be < split_time
      end
    end


    context 'request contains duplicate responses' do
      let(:num_responses) { 10 }

      let(:duplicate_response_data) { response_data.sample(3) }

      let(:request_payload) { {responses: duplicate_response_data + response_data} }

      it 'response has status 200' do
        response_status, response_body = record_responses(request_payload: request_payload)
        expect(response_status).to eq(200)
      end
      it 'response has list of recorded response uuids (duplicates are listed only once)' do
        response_status, response_body = record_responses(request_payload: request_payload)
        expect(response_body.fetch('recorded_response_uuids').sort).to eq(all_response_uuids.sort)
      end
      it 'creates Response records for only one of each duplicate set' do
        expect {
          record_responses(request_payload: request_payload)
        }.to change{ Response.count }.by 10
      end
    end

  end

end

def record_responses(request_payload:)
  make_post_request(
    route: '/record_responses',
    headers: { 'Content-Type' => 'application/json' },
    body:  request_payload.to_json
  )
  response_status  = response.status
  response_payload = JSON.parse(response.body)

  [response_status, response_payload]
end
