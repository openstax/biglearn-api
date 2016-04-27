require 'rails_helper'

describe 'POST /retrieve_precomputed_clues' do

  context 'with invalid uuid' do
    it 'returns 422 (unprocessable entity)', type: :request do
      payload = { 'precomputed_clue_uuids': [ SecureRandom::uuid.to_s ] }

      make_post_request(
        route: '/retrieve_precomputed_clues',
        headers: { 'Content-Type' => 'application/json' },
        body:  payload.to_json
      )
      # debugger
      expect(response.status).to eq(422)
    end
  end

end
