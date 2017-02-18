require 'rails_helper'

RSpec.describe EcosystemsController, type: :routing do
  context "POST /create_ecosystem" do
    it "routes to #create" do
      expect(post '/create_ecosystem').to route_to('ecosystems#create')
    end
  end

  context "POST /fetch_ecosystem_metadatas" do
    it "routes to #fetch_metadatas" do
      expect(post '/fetch_ecosystem_metadatas').to route_to('ecosystems#fetch_metadatas')
    end
  end

  context "POST /fetch_ecosystem_events" do
    it "routes to #fetch_events" do
      expect(post '/fetch_ecosystem_events').to route_to('ecosystems#fetch_events')
    end
  end
end
