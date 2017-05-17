require 'rails_helper'

RSpec.describe ExerciseExclusionsController, type: :routing do
  context "POST /update_course_excluded_exercises" do
    it "routes to #update_course" do
      expect(post '/update_course_excluded_exercises').to(
        route_to('exercise_exclusions#update_course')
      )
    end
  end

  context "POST /update_globally_excluded_exercises" do
    it "routes to #update_global" do
      expect(post '/update_globally_excluded_exercises').to(
        route_to('exercise_exclusions#update_global')
      )
    end
  end
end
