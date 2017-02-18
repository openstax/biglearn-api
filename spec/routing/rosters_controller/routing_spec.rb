require 'rails_helper'

RSpec.describe RostersController, type: :routing do
  context "POST /update_rosters" do
    it "routes to #update" do
      expect(post '/update_rosters').to route_to('rosters#update')
    end
  end
end
