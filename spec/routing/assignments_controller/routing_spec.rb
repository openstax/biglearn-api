require 'rails_helper'

RSpec.describe AssignmentsController, type: :routing do
  context "POST /create_update_assignments" do
    it "routes to #create_update" do
      expect(post '/create_update_assignments').to route_to('assignments#create_update')
    end
  end

  context "POST /fetch_assignment_pes" do
    it "routes to #fetch_pes" do
      expect(post '/fetch_assignment_pes').to route_to('assignments#fetch_pes')
    end
  end

  context "POST /fetch_assignment_spes" do
    it "routes to #fetch_spes" do
      expect(post '/fetch_assignment_spes').to route_to('assignments#fetch_spes')
    end
  end
end
