require 'rails_helper'

RSpec.describe AssignmentsController, type: :routing do
  context "POST /create_update_assignments" do
    it "routes to #create_update" do
      expect(post '/create_update_assignments').to route_to('assignments#create_update')
    end
  end
end
