require 'rails_helper'

RSpec.describe CourseEcosystemsController, type: :routing do
  context "POST /prepare_course_ecosystem" do
    it "routes to #prepare" do
      expect(post '/prepare_course_ecosystem').to route_to('course_ecosystems#prepare')
    end
  end

  context "POST /update_course_ecosystems" do
    it "routes to #update" do
      expect(post '/update_course_ecosystems').to route_to('course_ecosystems#update')
    end
  end

  context "POST /fetch_course_ecosystem_statuses" do
    it "routes to #update" do
      expect(post '/fetch_course_ecosystem_statuses').to route_to('course_ecosystems#status')
    end
  end
end
