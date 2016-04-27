require 'rails_helper'

describe 'POST /retrieve_precomputed_clues' do

  context 'with invalid uuid(s)' do
    it 'returns 422 (unprocessable entity) with appropriate error messages', type: :request do
      target_invalid_uuids = [ SecureRandom.uuid.to_s, SecureRandom.uuid.to_s ]

      response_status, response_payload = request_precomputed_clues(target_invalid_uuids)

      expect(response_status).to eq(422)
      target_invalid_uuids.each do |target_invalid_uuid|
        expect(response_payload['errors'].grep(/#{target_invalid_uuid}/)).to_not be_empty
      end
    end
  end

  context 'with valid uuid(s)' do
    it 'returns 200 (success) with appropriate number of precomputed CLUEs', type: :request do
      ## these are drawn from the currently hard-coded
      ## valid uuids in the controller
      target_valid_uuids = [
        "5913c263-f91d-4c83-af62-19d4619117f5",
        "38a89013-57da-4189-8534-d68db933776b",
        "7d2e17bd-50ff-4f80-a62b-a1f4e1dd6990"
      ]

      response_status, response_payload = request_precomputed_clues(target_valid_uuids)

      expect(response_status).to eq(200)
      expect(response_payload['precomputed_clues'].count).to eq(target_valid_uuids.count)
    end
  end

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
