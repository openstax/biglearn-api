require 'rails_helper'

RSpec.describe CoursesController, type: :routing do
  context "POST /create_course" do
    it "routes to #create" do
      expect(post '/create_course').to route_to('courses#create')
    end
  end

  context "POST /fetch_course_metadatas" do
    it "routes to #fetch_metadatas" do
      expect(post '/fetch_course_metadatas').to route_to('courses#fetch_metadatas')
    end
  end
end
