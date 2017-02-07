require 'rails_helper'

RSpec.describe Services::CreateCourse::Service do
  let(:service) { described_class.new }

  let(:action)  do
    service.process(course_uuid: given_course_uuid, ecosystem_uuid: given_ecosystem_uuid)
  end

  let(:given_course_uuid)    { SecureRandom.uuid }
  let(:given_ecosystem_uuid) { SecureRandom.uuid }

  context "and a previously-existing course_uuid is given" do
    before(:each) do
      FactoryGirl.create(:course_event, uuid: given_course_uuid, type: :create_course)
    end

    it "a CourseEvent is NOT created" do
      expect{action}.to_not change{CourseEvent.count}
    end

    it "the course_uuid is returned" do
      expect(action.fetch(:created_course_uuid)).to eq(given_course_uuid)
    end
  end

  context "and a previously non-existing course_uuid is given" do
    it "a CourseEvent is created" do
      expect{action}.to change{CourseEvent.count}.by(1)
    end

    it "the course_uuid is returned" do
      expect(action.fetch(:created_course_uuid)).to eq(given_course_uuid)
    end
  end
end
