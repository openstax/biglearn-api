require 'rails_helper'

RSpec.describe EcosystemEventsController, type: :routing do
  context "POST /fetch_ecosystem_events" do
    it "routes to #fetch" do
      expect(post '/fetch_ecosystem_events').to route_to('ecosystem_events#fetch')
    end
  end
end
