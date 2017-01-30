require 'rails_helper'

RSpec.describe ResponsesController, type: :routing do
  context "POST /record_responses" do
    it "routes to #record" do
      expect(post '/record_responses').to route_to('responses#record')
    end
  end
end
