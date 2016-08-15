require 'rails_helper'

RSpec.describe 'external API: /record_responses endpoint' do
  let(:trials) {
    100.times.map {
      {
        trial_uuid:    SecureRandom.uuid.to_s,
        learner_uuid:  SecureRandom.uuid.to_s,
        question_uuid: SecureRandom.uuid.to_s,
      }
    }
  }

  let(:responses) {
    responses = num_responses.times.map { |idx|
      trial = trials.sample

      response = {
        response_uuid:  SecureRandom.uuid.to_s,
        trial_uuid:     trial[:trial_uuid],
        trial_sequence: idx,
        learner_uuid:   trial[:learner_uuid],
        question_uuid:  trial[:question_uuid],
        is_correct:     [true, false].sample,
        responded_at:   Time.now,
      }
    }
  }

  let(:all_response_uuids) { responses.map{|response| response[:response_uuid]} }

  let(:request_payload) { {responses: responses} }

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
        expect(response_body['recorded_response_uuids'].sort).to eq(all_response_uuids.sort)
      end
      it 'the correct number of Response records are created' do
        expect{
          record_responses(request_payload: request_payload)
        }.to change { Response.count }.by(num_responses)
      end
      it 'the created Response records have the correct parameters' do
        record_responses(request_payload: request_payload)

        recorded_responses = Response.find_each.to_a
        response_data_by_response_uuid = responses.inject({}){ |result, response|
          result[response[:response_uuid]] = response
          result
        }
        recorded_responses.each do |recorded_response|
          target_response_data = response_data_by_response_uuid[recorded_response.response_uuid]
          aggregate_failures 'response param checks' do
            expect(recorded_response.response_uuid).to  eq(target_response_data[:response_uuid])
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
        responses.sample(10).map do |data|
          Response.create!(data)
          data[:response_uuid]
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
        sleep(0.01)

        expect {
          record_responses(request_payload: request_payload)
        }.to change{ Response.count }.by(40)
        target_response_uuids = Response.where{created_at > split_time}.map(&:response_uuid).to_a

        expect(target_response_uuids.sort).to eq(newly_recorded_response_uuids.sort)
      end
      it 'does not alter previously-recorded Response records' do
        split_time = Time.now
        sleep(0.01)

        record_responses(request_payload: request_payload)
        target_response_updated_times = Response.where{created_at < split_time}.map(&:updated_at).to_a

        expect(target_response_updated_times.count).to eq(10)
        expect(target_response_updated_times.max).to be < split_time
      end
    end


    context 'request contains duplicate responses' do
      let(:num_responses) { 10 }

      let(:duplicate_responses) { responses.sample(3) }

      let(:request_payload) { {responses: duplicate_responses + responses} }

      it 'response has status 200' do
        response_status, response_body = record_responses(request_payload: request_payload)
        expect(response_status).to eq(200)
      end
      it 'response has list of recorded response uuids (duplicates are listed only once)' do
        response_status, response_body = record_responses(request_payload: request_payload)
        expect(response_body['recorded_response_uuids'].sort).to eq(all_response_uuids.sort)
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
