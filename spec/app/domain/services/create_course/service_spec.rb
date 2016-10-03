require 'rails_helper'

RSpec.describe Services::CreateCourse::Service do
  let(:service) { Services::CreateCourse::Service.new }
  let(:action) { process }

  def process
    service.process(course_uuid: given_course_uuid, ecosystem_uuid: given_ecosystem_uuid)
  end

  context "when non-existing ecosystem is given" do
    let(:given_course_uuid) { SecureRandom.uuid.to_s }
    let(:given_ecosystem_uuid) { SecureRandom.uuid.to_s }

    let!(:split_time) { time = Time.now; sleep(0.001); time }

    it "raises error" do
      expect{action}.to raise_error(Errors::AppUnprocessableError)
    end
  end

  context "when existing ecosystem is given" do

    ecosystem_uuid = SecureRandom.uuid.to_s
    course_uuid = SecureRandom.uuid.to_s

    let(:given_course_uuid) { course_uuid }
    let(:given_ecosystem_uuid) { ecosystem_uuid }

    let!(:split_time) { time = Time.now; sleep(0.001); time }

    expected = {created_course_uuid: course_uuid}

    before(:each) do
      Ecosystem.find_or_create_by(uuid: ecosystem_uuid)
    end

    it "Course is created" do
      expect{action}.to change{Course.count}
    end

    it "created_course_uuid is returned" do
      expect(action).to eq expected
    end

    it "Course is updated" do
      action

      updated_courses = Course.where{updated_at > my{split_time}}
      expect(updated_courses).to_not be_empty
    end
  end

  context "when existing course is given" do

    ecosystem_uuid = SecureRandom.uuid.to_s
    course_uuid = SecureRandom.uuid.to_s

    let(:given_course_uuid) { course_uuid }
    let(:given_ecosystem_uuid) { ecosystem_uuid }

    expected = {created_course_uuid: course_uuid}

    let!(:split_time) { time = Time.now; sleep(0.001); time }

    before(:each) do
      Ecosystem.find_or_create_by(uuid: ecosystem_uuid)
      process
    end

    it "Course is not created" do
      expect{process}.to_not change{Course.count}
    end

    it "created_course_uuid is returned" do
      expect(process).to eq expected
    end

  end

end

