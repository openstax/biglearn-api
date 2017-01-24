require 'rails_helper'

RSpec.describe CoursesController, type: :routing do
  context "POST /create_course" do
    it "routes to #create" do
      expect(post '/create_course').to route_to('courses#create')
    end
  end
end
