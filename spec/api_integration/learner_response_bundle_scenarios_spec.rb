require 'rails_helper'

RSpec.describe 'learner response bundle scenarios' do
  context 'malformed request' do
    context 'number of requested bundles exceeds maximum' do
      xit 'returns status 400 (bad request)'
      xit 'returns appropriate error message(s)'
    end
  end
  context 'no learner response bundles exist' do
    context 'request does not confirm any bundles' do
      xit 'returns status 200 (success)'
      xit 'returns no bundles'
    end
    context 'request confirms bundles' do
      xit 'returns status 422 (unprocessable entity)'
      xit 'returns appropriate error message(s)'
    end
  end
  context 'learner response bundles exist' do
    ## sent/unsent
    ## confirmed/unconfirmed
    ## open/closed
    ## multiple writer modulos
    ## multiple reader modulos
    context 'request does not confirm any bundles' do
      xit 'returns status 200 (success)'
      xit 'returns previously sent, unconfirmed bundles'
      xit 'returns previously unsent bundles'
      xit 'updates sent status closed bundles'
      xit 'does not update sent status of open bundles'
      xit 'prioritizes sending of closed bundles over open bundles'
      xit 'does not return previously confirmed, closed bundles'
      xit 'returns only bundles with appropriate reader modulo'
      xit 'returns no confirmed bundle uuids'
    end
    context 'request does confirm bundles' do
      xit 'returns status 200 (success)'
      xit 'returns previously sent, unconfirmed bundles'
      xit 'returns previously unsent bundles'
      xit 'updates sent status closed bundles'
      xit 'does not update sent status of open bundles'
      xit 'updates confirm status of sent, closed bundles'
      xit 'does not update confirm status of open bundles'
      xit 'prioritizes sending of closed bundles over open bundles'
      xit 'does not return previously confirmed, closed bundles'
      xit 'does not return newly confirmed, closed bundles'
      xit 'returns only bundles with appropriate reader modulo'
      xit 'returns confirmed bundle uuids'
    end
  end
end
