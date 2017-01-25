require 'rails_helper'

RSpec.describe CourseExerciseExclusionsController, type: :routing do
  context "POST /update_course_excluded_exercises" do
    it "routes to #update" do
      expect(post '/update_course_excluded_exercises').to(
        route_to('course_exercise_exclusions#update')
      )
    end
  end
end
