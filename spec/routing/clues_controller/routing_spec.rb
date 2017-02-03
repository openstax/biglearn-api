require 'rails_helper'

RSpec.describe CluesController, type: :routing do
  context "POST /fetch_student_clues" do
    it "routes to #student" do
      expect(post '/fetch_student_clues').to route_to('clues#student')
    end
  end

  context "POST /fetch_teacher_clues" do
    it "routes to #teacher" do
      expect(post '/fetch_teacher_clues').to route_to('clues#teacher')
    end
  end
end
