require 'rails_helper'

RSpec.describe ResponseBundlesController, type: :routing do
  context "POST /fetch_response_bundles" do
    it "routes to #fetch" do
      expect(post '/fetch_response_bundles').to route_to('response_bundles#fetch')
    end
  end
end
