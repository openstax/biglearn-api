require 'rails_helper'

RSpec.describe 'new learner response scenarios' do
  context 'malformed request' do
    context 'number of learner responses exceeds maximum' do
      xit 'returns status 400 (bad request)'
      xit 'returns appropriate error message(s)'
    end
  end
  context 'no learner responses' do
    xit 'does not save any learner responses'
    xit 'returns status 200 (success)'
    xit 'returns a list saved learner response uuids (none)'
  end
  context 'learner responses' do
    ## previously saved/unsaved
    ## valud/invalid
    xit 'saves the new learner responses'
    xit 'returns status 200 (success)'
    xit 'returns a list of saved learner response uuids'
    xit 'returns a list of not-saved learner response uuids'
    xit 'returns re-saved learner response uuids (saves are idempotent)'
  end
end
