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
    xit 'returns a count of saved learner responses (zero)'
  end
  context 'invalid learner responses' do
    context 'inconsistent trial definition' do
      xit 'saves consistent learner responses'
      xit 'does not save inconsistent learner responses'
      xit 'returns status 207 (multi-status)'
      xit 'returns appropriate error message(s)'
    end
  end
  context 'valid learner responses' do
    context 'with no repeats' do
      xit 'saves the new learner responses'
      xit 'returns status 200 (success)'
      xit 'returns the count of saved learner responses'
    end
    context 'with only repeats' do
      xit 'does not save any learner responses'
      xit 'returns status 200 (success)'
      xit 'returns a count of saved learner responses (zero)'
    end
    context 'with some repeats' do
      xit 'saves only non-repeat learner responses'
      xit 'returns status 200 (success)'
      xit 'returns a count of saved learner responses'
    end
  end
end
