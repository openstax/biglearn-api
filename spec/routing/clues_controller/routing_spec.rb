require 'rails_helper'

RSpec.describe CluesController, type: :routing do
  context "POST /fetch_student_clues" do
    it "routes to #fetch_student" do
      expect(post '/fetch_student_clues').to route_to('clues#fetch_student')
    end
  end

  context "POST /fetch_teacher_clues" do
    it "routes to #fetch_teacher" do
      expect(post '/fetch_teacher_clues').to route_to('clues#fetch_teacher')
    end
  end

  context "POST /update_student_clues" do
    it "routes to #update_student" do
      expect(post '/update_student_clues').to route_to('clues#update_student')
    end
  end

  context "POST /update_teacher_clues" do
    it "routes to #update_teacher" do
      expect(post '/update_teacher_clues').to route_to('clues#update_teacher')
    end
  end
end
