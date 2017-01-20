require 'rails_helper'

RSpec.describe Services::CreateCourse::Service do
  let(:service) { described_class.new }

  let(:action) { service.process(course_uuid: given_course_uuid, ecosystem_uuid: given_ecosystem_uuid) }

  let(:given_course_uuid)    { SecureRandom.uuid }
  let(:given_ecosystem_uuid) { SecureRandom.uuid }

  context "when previously non-existing Ecosystem uuid is given" do
    it "raises error" do
      expect{action}.to raise_error(Errors::AppUnprocessableError)
    end
  end

  context "when previously-existing Ecosystem uuid is given" do
    before(:each) do
      create(:ecosystem, uuid: given_ecosystem_uuid)
    end

    context "and a previously-existing Course uuid is given" do
      before(:each) do
        create(:course, uuid: given_course_uuid)
      end

      it "a Course is NOT created" do
        expect{action}.to_not change{Course.count}
      end

      it "the Course's uuid is returned" do
        expect(action.fetch(:created_course_uuid)).to eq(given_course_uuid)
      end
    end

    context "and a previously non-existing Course uuid is given" do
      it "a Course is created" do
        expect{action}.to change{Course.count}.by(1)
      end

      it "the Course's uuid is returned" do
        expect(action.fetch(:created_course_uuid)).to eq(given_course_uuid)
      end
    end
  end
end
