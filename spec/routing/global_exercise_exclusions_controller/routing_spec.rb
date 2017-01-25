require 'rails_helper'

RSpec.describe GlobalExerciseExclusionsController, type: :routing do
  context "POST /update_globally_excluded_exercises" do
    it "routes to #update" do
      expect(post '/update_globally_excluded_exercises').to(
        route_to('global_exercise_exclusions#update')
      )
    end
  end
end
