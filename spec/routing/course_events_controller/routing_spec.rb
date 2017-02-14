require 'rails_helper'

RSpec.describe CourseEventsController, type: :routing do
  context "POST /fetch_course_events" do
    it "routes to #fetch" do
      expect(post '/fetch_course_events').to route_to('course_events#fetch')
    end
  end
end
