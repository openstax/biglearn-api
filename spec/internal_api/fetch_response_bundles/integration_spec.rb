require 'rails_helper'

RSpec.describe 'internal API: /fetch_response_bundles endpoint' do
  let(:request_payload) {
    {
      max_bundles_to_return:  max_bundles_to_return,
      confirmed_bundle_uuids: confirmed_bundle_uuids,
      receiver_info: {
        receiver_uuid:    target_receiver_uuid,
        partition_count:  partition_count,
        partition_modulo: target_partition_modulo,
      },
    }
  }

  let(:max_bundles_to_return)   { 0 }
  let(:confirmed_bundle_uuids)  { [] }
  let(:target_receiver_uuid)    { SecureRandom.uuid.to_s }
  let(:nontarget_receiver_uuid) { SecureRandom.uuid.to_s }

  let(:partition_count)            { 5 }
  let(:target_partition_modulo)    { 3 }
  let(:nontarget_partition_modulo) { 2 }
  let(:target_partition)           { [partition_count, target_partition_modulo]    }
  let(:nontarget_partition)        { [partition_count, nontarget_partition_modulo] }

  let(:tr) { target_receiver_uuid }
  let(:nr) { nontarget_receiver_uuid }
  let(:tp) { target_partition }
  let(:np) { nontarget_partition }

  let(:bundle_params) { [] }

  before(:each) do
    @response_bundle_uuids = create_bundles(bundle_params: bundle_params)
  end
  let(:response_bundle_uuids) { @response_bundle_uuids }

  let(:target_closed_sent_unconfirmed_bundle_uuids) {
    response_bundle_uuids.zip(bundle_params).select{ |bundle_uuid, params|
      (params.fetch(:partition) == target_partition) &&
      !params.fetch(:is_open) &&
      !params.fetch(:sent_to).empty? &&
      !params.fetch(:confirmed_by).include?(target_receiver_uuid)
    }.map(&:first)
  }

  let(:target_confirmed_bundle_uuids) {
    response_bundle_uuids.zip(bundle_params).select{ |bundle_uuid, params|
      (params.fetch(:partition) == target_partition) &&
      !params.fetch(:is_open) &&
      params.fetch(:sent_to).include?(target_receiver_uuid) &&
      params.fetch(:confirmed_by).include?(target_receiver_uuid)
    }.map(&:first)
  }

  let(:target_unconfirmed_bundle_uuids) {
    response_bundle_uuids.zip(bundle_params).select{ |bundle_uuid, params|
      (params.fetch(:partition) == target_partition) &&
      !params.fetch(:confirmed_by).include?(target_receiver_uuid)
    }.map(&:first)
  }

  let(:target_closed_unconfirmed_bundle_uuids) {
    response_bundle_uuids.zip(bundle_params).select{ |bundle_uuid, params|
      (params.fetch(:partition) == target_partition) &&
      !params.fetch(:is_open) &&
      !params.fetch(:confirmed_by).include?(target_receiver_uuid)
    }.map(&:first)
  }

  let(:target_unsent_bundle_uuids) {
    response_bundle_uuids.zip(bundle_params).select{ |bundle_uuid, params|
      (params.fetch(:partition) == target_partition) &&
      !params.fetch(:sent_to).include?(target_receiver_uuid) &&
      !params.fetch(:confirmed_by).include?(target_receiver_uuid)
    }.map(&:first)
  }

  let(:target_open_bundle_uuids) {
    response_bundle_uuids.zip(bundle_params).select{ |bundle_uuid, params|
      (params.fetch(:partition) == target_partition) &&
      params.fetch(:is_open) &&
      !params.fetch(:sent_to).include?(target_receiver_uuid) &&
      !params.fetch(:confirmed_by).include?(target_receiver_uuid)
    }.map(&:first)
  }

  let(:target_closed_unsent_unconfirmed_uuids) {
    response_bundle_uuids.zip(bundle_params).select{ |bundle_uuid, params|
      (params.fetch(:partition) == target_partition) &&
      !params.fetch(:is_open) &&
      !params.fetch(:sent_to).include?(target_receiver_uuid) &&
      !params.fetch(:confirmed_by).include?(target_receiver_uuid)
    }.map(&:first)
  }

  let(:target_closed_unconfirmed_bundle_uuids) {
    response_bundle_uuids.zip(bundle_params).select{ |bundle_uuid, params|
      (params.fetch(:partition) == target_partition) &&
      !params.fetch(:is_open) &&
      !params.fetch(:confirmed_by).include?(target_receiver_uuid)
    }.map(&:first)
  }

  let(:target_sent_unconfirmed_bundle_uuids) {
    response_bundle_uuids.zip(bundle_params).select{ |bundle_uuid, params|
      (params.fetch(:partition) == target_partition) &&
      params.fetch(:sent_to).include?(target_receiver_uuid) &&
      !params.fetch(:confirmed_by).include?(target_receiver_uuid)
    }.map(&:first)
  }


  context 'when the request is malformed', type: :request do

    shared_examples "malformed request common examples" do
      it 'no ResponseBundleReceipt records are created' do
        expect{
          fetch_response_bundles(request_payload: request_payload)
        }.to_not change{ ResponseBundleReceipt.count }
      end
      it 'no ResponseBundleConfirmation records are created' do
        expect{
          fetch_response_bundles(request_payload: request_payload)
        }.to_not change{ ResponseBundleConfirmation.count }
      end
      it 'the response has status 400 (bad request)' do
        response_status, response_payload = fetch_response_bundles(request_payload: request_payload)
        expect(response_status).to eq(400)
      end
    end

    context 'because required fields are missing' do
      let(:request_payload) { {} }

      include_examples "malformed request common examples"

      it 'the response body has appropriate error message(s)' do
        response_status, response_payload = fetch_response_bundles(request_payload: request_payload)
        aggregate_failures 'error message checks' do
          [:max_bundles_to_return, :confirmed_bundle_uuids, :receiver_info].each do |field|
            expect(response_payload['errors'].grep(/did not contain.*#{field}/)).to_not be_empty
          end
        end
      end
    end

    context 'because "max_bundles_to_return" exceeds maximum allowed' do
      let(:max_bundles_to_return) { 1001 }

      include_examples "malformed request common examples"

      it 'the response body has appropriate error message(s)' do
        response_status, response_payload = fetch_response_bundles(request_payload: request_payload)
        expect(response_payload['errors'].grep(/max_bundles_to_return.*maximum/)).to_not be_empty
      end
    end

  end

  context 'when the request is valid', type: :request do

    context 'response status:' do
      it 'the response has status 200 (success)' do
        response_status, response_payload = fetch_response_bundles(request_payload: request_payload)
        expect(response_status).to eq(200)
      end
    end

    context 'returned bundle confirmations:' do
      let(:bundle_params) {
        [
          { partition: np, is_open: false, sent_to: [],    confirmed_by: [],    num_responses: 1 },
          { partition: np, is_open: false, sent_to: [tr],  confirmed_by: [],    num_responses: 1 },
          { partition: np, is_open: false, sent_to: [tr],  confirmed_by: [tr],  num_responses: 1 },
          { partition: np, is_open: true,  sent_to: [],    confirmed_by: [],    num_responses: 1 },
        ]
      }

      context 'when the request contains newly-confirmed response bundle uuids' do
        let(:confirmed_bundle_uuids) { target_closed_sent_unconfirmed_bundle_uuids * 2 }

        it 'new ResponseBundleConfirmation records are created' do
          split_time = Time.now
          sleep(0.002)

          aggregate_failures 'checks' do
            expect{
              fetch_response_bundles(request_payload: request_payload)
            }.to change{ ResponseBundleConfirmation.count }.by(target_closed_sent_unconfirmed_bundle_uuids.count)

            newly_confirmed_bundle_uuids = ResponseBundleConfirmation.where{created_at > split_time}
                                                                     .to_a
                                                                     .map{|rbc| rbc.response_bundle_uuid}

            expect(newly_confirmed_bundle_uuids.sort).to eq(target_closed_sent_unconfirmed_bundle_uuids.sort)
          end
        end
        it 'the response contains the newly-confirmed response bundle uuids' do
          response_status, response_payload = fetch_response_bundles(request_payload: request_payload)
          expect(response_payload['confirmed_bundle_uuids'].sort).to eq(target_closed_sent_unconfirmed_bundle_uuids.sort)
        end
      end

      context 'when the request contains previously-confirmed response bundle uuids' do
        let(:confirmed_bundle_uuids) { target_confirmed_bundle_uuids * 2 }

        it 'new ResponseBundleConfirmation records are NOT created' do
          expect{
            fetch_response_bundles(request_payload: request_payload)
          }.to_not change{ ResponseBundleConfirmation.count }
        end
        it 'the response contains the previously-confirmed response bundle uuids (idempotence)' do
          response_status, response_payload = fetch_response_bundles(request_payload: request_payload)
          expect(response_payload['confirmed_bundle_uuids'].sort).to eq(target_confirmed_bundle_uuids.sort)
        end
      end

      context 'when the request contains invalid response bundle uuids' do
        let(:confirmed_bundle_uuids) { 3.times.map{ SecureRandom.uuid.to_s } }

        it 'new ResponseBundleConfirmation records are NOT created' do
          expect{
            fetch_response_bundles(request_payload: request_payload)
          }.to_not change{ ResponseBundleConfirmation.count }
        end
        it 'the response contains no confirmed response bundle uuids' do
          response_status, response_payload = fetch_response_bundles(request_payload: request_payload)
          expect(response_payload['confirmed_bundle_uuids']).to be_empty
        end
      end

      context 'when the request contains unsent response bundle uuids' do
        let(:confirmed_bundle_uuids) { target_unsent_bundle_uuids * 2 }

        it 'new ResponseBundleConfirmation records are NOT created' do
          expect{
            fetch_response_bundles(request_payload: request_payload)
          }.to_not change{ ResponseBundleConfirmation.count }
        end
        it 'the response contains no confirmed response bundle uuids' do
          response_status, response_payload = fetch_response_bundles(request_payload: request_payload)
          expect(response_payload['confirmed_bundle_uuids']).to be_empty
        end
      end

      context 'when the request contains open response bundle uuids' do
        let(:confirmed_bundle_uuids) { target_open_bundle_uuids * 2 }

        it 'new ResponseBundleConfirmation records are NOT created' do
          expect{
            fetch_response_bundles(request_payload: request_payload)
          }.to_not change{ ResponseBundleConfirmation.count }
        end
        it 'the response contains no confirmed response bundle uuids' do
          response_status, response_payload = fetch_response_bundles(request_payload: request_payload)
          expect(response_payload['confirmed_bundle_uuids']).to be_empty
        end
      end

    end

    context 'returned response bundle uuids:' do

      context 'when there are no response bundles' do
        let(:bundle_params) { [] }

        let(:max_bundles_to_return) { 5 }

        it 'the response contains no response bundle uuids' do
          response_status, response_payload = fetch_response_bundles(request_payload: request_payload)
          expect(response_payload['bundle_uuids']).to be_empty
        end
      end

      context 'when the request asks for at most zero response bundles' do
        let(:bundle_params) {
          [
            { partition: np,  is_open: false,  sent_to: [],  confirmed_by: [],  num_responses: 1 },
            { partition: tp,  is_open: false,  sent_to: [],  confirmed_by: [],  num_responses: 1 },
          ]
        }

        let(:max_bundles_to_return) { 0 }

        it 'the response contains no response bundle uuids' do
          response_status, response_payload = fetch_response_bundles(request_payload: request_payload)
          expect(response_payload['bundle_uuids']).to be_empty
        end
      end

      context 'when the request asks for more response bundles than can be returned' do
        let(:bundle_params) {
          [
            { partition: np,  is_open: false,  sent_to: [],  confirmed_by: [],  num_responses: 1 },
            { partition: tp,  is_open: false,  sent_to: [],  confirmed_by: [],  num_responses: 1 },
            { partition: np,  is_open: false,  sent_to: [],  confirmed_by: [],  num_responses: 1 },
          ]
        }

        let(:max_bundles_to_return) { 10 }

        it 'the response contains the returnable response bundle uuids' do
          response_status, response_payload = fetch_response_bundles(request_payload: request_payload)
          expect(response_payload['bundle_uuids']).to match_array(target_unconfirmed_bundle_uuids)
        end
      end

      context 'when the request asks for fewer response bundles than can be returned' do
        let(:bundle_params) {
          [
            { partition: np,  is_open: false,  sent_to: [],  confirmed_by: [],  num_responses: 1 },
            { partition: tp,  is_open: false,  sent_to: [],  confirmed_by: [],  num_responses: 1 },
            { partition: tp,  is_open: false,  sent_to: [],  confirmed_by: [],  num_responses: 1 },
            { partition: tp,  is_open: false,  sent_to: [],  confirmed_by: [],  num_responses: 1 },
            { partition: np,  is_open: false,  sent_to: [],  confirmed_by: [],  num_responses: 1 },
          ]
        }

        let(:max_bundles_to_return) { 2 }

        it 'the response contains the requested number of response bundle uuids' do
          response_status, response_payload = fetch_response_bundles(request_payload: request_payload)
          expect(response_payload['bundle_uuids'].count).to eq(max_bundles_to_return)
        end
      end

      context 'when both open and closed bundle uuids can be returned' do
        let(:bundle_params) {
          [
            { partition: np,  is_open: false,  sent_to: [],  confirmed_by: [],  num_responses: 1 },
            { partition: tp,  is_open: true,   sent_to: [],  confirmed_by: [],  num_responses: 1 },
            { partition: tp,  is_open: false,  sent_to: [],  confirmed_by: [],  num_responses: 1 },
            { partition: tp,  is_open: false,  sent_to: [],  confirmed_by: [],  num_responses: 1 },
            { partition: tp,  is_open: true,   sent_to: [],  confirmed_by: [],  num_responses: 1 },
            { partition: np,  is_open: false,  sent_to: [],  confirmed_by: [],  num_responses: 1 },
          ]
        }

        let(:max_bundles_to_return) { 2 }

        it 'all closed bundle uuids are returned before any open bundle uuid' do
          response_status, response_payload = fetch_response_bundles(request_payload: request_payload)
          expect(response_payload['bundle_uuids']).to match_array(target_closed_unconfirmed_bundle_uuids)
        end
      end

      context 'when there previously-sent, unconfirmed bundles' do
        let(:bundle_params) {
          [
            { partition: np,  is_open: false,  sent_to: [tr],  confirmed_by: [],    num_responses: 1 },
            { partition: tp,  is_open: false,  sent_to: [tr],  confirmed_by: [],    num_responses: 1 },
            { partition: tp,  is_open: false,  sent_to: [tr],  confirmed_by: [tr],  num_responses: 1 },
            { partition: tp,  is_open: false,  sent_to: [tr],  confirmed_by: [],    num_responses: 1 },
            { partition: np,  is_open: false,  sent_to: [tr],  confirmed_by: [],    num_responses: 1 },
          ]
        }

        let(:max_bundles_to_return) { 2 }

        it 'the response contains the previously-sent, unconfirmed bundle uuids' do
          response_status, response_payload = fetch_response_bundles(request_payload: request_payload)
          expect(response_payload['bundle_uuids']).to match_array(target_sent_unconfirmed_bundle_uuids)
        end
      end

      context 'when there are no unconfirmed bundles' do
        let(:bundle_params) {
          [
            { partition: np,  is_open: false,  sent_to: [],    confirmed_by: [],    num_responses: 1 },
            { partition: tp,  is_open: false,  sent_to: [tr],  confirmed_by: [tr],  num_responses: 1 },
            { partition: tp,  is_open: false,  sent_to: [tr],  confirmed_by: [tr],  num_responses: 1 },
            { partition: np,  is_open: false,  sent_to: [],    confirmed_by: [],    num_responses: 1 },
          ]
        }

        let(:max_bundles_to_return) { 3 }

        it 'the response contains no bundle uuids' do
          response_status, response_payload = fetch_response_bundles(request_payload: request_payload)
          expect(response_payload['bundle_uuids']).to be_empty
        end
      end

      context 'when the response contains bundle uuids' do
        let(:bundle_params) {
          [
            { partition: np,  is_open: false,  sent_to: [],    confirmed_by: [],    num_responses: 1 },
            { partition: tp,  is_open: false,  sent_to: [],    confirmed_by: [],    num_responses: 1 },
            { partition: tp,  is_open: false,  sent_to: [tr],  confirmed_by: [],    num_responses: 1 },
            { partition: tp,  is_open: false,  sent_to: [tr],  confirmed_by: [tr],  num_responses: 1 },
            { partition: tp,  is_open: true,   sent_to: [],    confirmed_by: [],    num_responses: 1 },
            { partition: np,  is_open: false,  sent_to: [],    confirmed_by: [],    num_responses: 1 },
          ]
        }

        let(:max_bundles_to_return) { 10 }

        it 'all bundle uuids match the partition count/modulo' do
          response_status, response_payload = fetch_response_bundles(request_payload: request_payload)
          expect(response_payload['bundle_uuids']).to match_array(target_unconfirmed_bundle_uuids)
        end

        it 'new ResponseBundleReceipt records are created for ONLY newly-sent, closed response bundles' do
          split_time = Time.now
          sleep(0.002)

          aggregate_failures 'checks' do
            expect {
              fetch_response_bundles(request_payload: request_payload)
            }.to change{ ResponseBundleReceipt.count }.by(1)

            expect(ResponseBundleReceipt.where{created_at > split_time}.map(&:response_bundle_uuid))
              .to match_array(target_closed_unsent_unconfirmed_uuids)
          end
        end
      end

    end

    context 'returned response data:' do

      context 'when the response contains no bundle uuids' do
        let(:bundle_params) {
          [
            { partition: np,  is_open: false,  sent_to: [],    confirmed_by: [],    num_responses:  1 },
            { partition: tp,  is_open: false,  sent_to: [tr],  confirmed_by: [tr],  num_responses:  1 },
            { partition: np,  is_open: false,  sent_to: [],    confirmed_by: [],    num_responses:  1 },
          ]
        }

        let(:max_bundles_to_return) { 10 }

        it 'the response contains no response data' do
          response_status, response_payload = fetch_response_bundles(request_payload: request_payload)
          expect(response_payload['responses']).to be_empty
        end
      end

      context 'when the response contains bundle uuids' do
        let(:bundle_params) {
          [
            { partition: np,  is_open: false,  sent_to: [],    confirmed_by: [],    num_responses:  1 },
            { partition: tp,  is_open: false,  sent_to: [],    confirmed_by: [],    num_responses:  2 },
            { partition: tp,  is_open: false,  sent_to: [tr],  confirmed_by: [],    num_responses:  4 },
            { partition: tp,  is_open: false,  sent_to: [tr],  confirmed_by: [tr],  num_responses:  8 },
            { partition: tp,  is_open: true,   sent_to: [],    confirmed_by: [],    num_responses: 16 },
            { partition: np,  is_open: false,  sent_to: [],    confirmed_by: [],    num_responses: 32 },
          ]
        }

        let(:max_bundles_to_return) { 10 }

        it 'the response contains ONLY response data from those bundles' do
          response_status, response_payload = fetch_response_bundles(request_payload: request_payload)
          expect(response_payload['responses'].count).to eq(22)
        end
        it 'the response data is correct' do
          response_status, response_payload = fetch_response_bundles(request_payload: request_payload)

          target_response_uuids = ResponseBundleEntry.where{response_bundle_uuid.in response_payload['bundle_uuids']}
                                                     .map(&:response_uuid)

          target_responses = Response.where{response_uuid.in target_response_uuids}.to_a

          aggregate_failures 'response data check' do
            target_responses.each { |target_response|
              target_response_data = response_payload['responses'].detect{ |response_data|
                response_data['response_uuid'] == target_response.response_uuid
              }
              expect(target_response_data['response_uuid']).to  eq(target_response.response_uuid)
              expect(target_response_data['trial_uuid']).to     eq(target_response.trial_uuid)
              expect(target_response_data['trial_sequence']).to eq(target_response.trial_sequence)
              expect(target_response_data['learner_uuid']).to   eq(target_response.learner_uuid)
              expect(target_response_data['question_uuid']).to  eq(target_response.question_uuid)
              expect(target_response_data['is_correct']).to     eq(target_response.is_correct)
              expect(Chronic.parse(target_response_data['responded_at']) - target_response.responded_at).to be < 0.01.seconds
            }
          end
        end
      end

    end

  end

end


def fetch_response_bundles(request_payload:)
  make_post_request(
    route: '/fetch_response_bundles',
    headers: { 'Content-Type' => 'application/json' },
    body:  request_payload.to_json
  )
  response_status  = response.status
  response_payload = JSON.parse(response.body)

  [response_status, response_payload]
end


def create_modulo_uuid(partition_count:,
                       partition_modulo:)
  begin
    uuid = SecureRandom.uuid.to_s
  end while (uuid_as_number(uuid) % partition_count != partition_modulo)
  uuid
end


def uuid_as_number(uuid)
  uuid.split('-').last.hex
end


def create_bundles(bundle_params:)
  response_bundle_uuids = bundle_params.map do |params|
    response_uuids = create_responses(count: params.fetch(:num_responses))

    response_bundle_uuid = create_modulo_uuid(
      partition_count:  params.fetch(:partition)[0],
      partition_modulo: params.fetch(:partition)[1],
    )

    ResponseBundle.create!(
      response_bundle_uuid: response_bundle_uuid,
      is_open: params.fetch(:is_open)
    )

    response_uuids.map do |response_uuid|
      ResponseBundleEntry.create!(
        response_bundle_uuid: response_bundle_uuid,
        response_uuid:        response_uuid,
      )
    end

    params.fetch(:sent_to).each do |receiver_uuid|
      ResponseBundleReceipt.create!(
        response_bundle_uuid: response_bundle_uuid,
        receiver_uuid:        receiver_uuid,
      )
    end

    params.fetch(:confirmed_by).each do |receiver_uuid|
      ResponseBundleConfirmation.create!(
        response_bundle_uuid: response_bundle_uuid,
        receiver_uuid:        receiver_uuid,
      )
    end

    response_bundle_uuid
  end
  response_bundle_uuids
end


def create_responses(count:)
  counter = Response.count + 1

  response_uuids = count.times.map do
    response_uuid = SecureRandom.uuid.to_s

    Response.create!(
      response_uuid:  response_uuid,
      trial_uuid:     SecureRandom.uuid.to_s,
      trial_sequence: (counter += 1),
      learner_uuid:   SecureRandom.uuid.to_s,
      question_uuid:  SecureRandom.uuid.to_s,
      is_correct:     [true, false].sample,
      responded_at:   Time.now,
    )

    response_uuid
  end
  response_uuids
end

