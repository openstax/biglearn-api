require 'rails_helper'

RSpec.describe CourseActiveDatesController, type: :routing do
  context "POST /update_course_active_dates" do
    it "routes to #update" do
      expect(post '/update_course_active_dates').to route_to('course_active_dates#update')
    end
  end
end
