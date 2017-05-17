require 'rails_helper'

RSpec.describe CoursesController, type: :routing do
  context "POST /create_course" do
    it "routes to #create" do
      expect(post '/create_course').to route_to('courses#create')
    end
  end

  context "POST /update_course_active_dates" do
    it "routes to #update_active_dates" do
      expect(post '/update_course_active_dates').to route_to('courses#update_active_dates')
    end
  end

  context "POST /fetch_course_metadatas" do
    it "routes to #fetch_metadatas" do
      expect(post '/fetch_course_metadatas').to route_to('courses#fetch_metadatas')
    end
  end

  context "POST /fetch_course_events" do
    it "routes to #fetch_events" do
      expect(post '/fetch_course_events').to route_to('courses#fetch_events')
    end
  end
end
