require 'rails_helper'

RSpec.describe RostersController, type: :routing do
  context "POST /update_roster" do
    it "routes to #update" do
      expect(post '/update_roster').to route_to('rosters#update')
    end
  end
end
