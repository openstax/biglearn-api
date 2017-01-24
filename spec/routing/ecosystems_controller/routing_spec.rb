require 'rails_helper'

RSpec.describe EcosystemsController, type: :routing do
  context "POST /create_ecosystem" do
    it "routes to #create" do
      expect(post '/create_ecosystem').to route_to('ecosystems#create')
    end
  end
end
