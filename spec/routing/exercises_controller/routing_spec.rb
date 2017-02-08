require 'rails_helper'

RSpec.describe AssignmentsController, type: :routing do
  context "POST /fetch_assignment_pes" do
    it "routes to #fetch_assignment_pes" do
      expect(post '/fetch_assignment_pes').to route_to('exercises#fetch_assignment_pes')
    end
  end

  context "POST /fetch_assignment_spes" do
    it "routes to #fetch_assignment_spes" do
      expect(post '/fetch_assignment_spes').to route_to('exercises#fetch_assignment_spes')
    end
  end

  context "POST /fetch_practice_worst_areas_exercises" do
    it "routes to #fetch_practice_worst_areas" do
      expect(post '/fetch_practice_worst_areas_exercises').to(
        route_to('exercises#fetch_practice_worst_areas')
      )
    end
  end

  context "POST /update_assignment_pes" do
    it "routes to #update_assignment_pes" do
      expect(post '/update_assignment_pes').to route_to('exercises#update_assignment_pes')
    end
  end

  context "POST /update_assignment_spes" do
    it "routes to #update_assignment_spes" do
      expect(post '/update_assignment_spes').to route_to('exercises#update_assignment_spes')
    end
  end

  context "POST /update_practice_worst_areas_exercises" do
    it "routes to #update_practice_worst_areas" do
      expect(post '/update_practice_worst_areas_exercises').to(
        route_to('exercises#update_practice_worst_areas')
      )
    end
  end
end
