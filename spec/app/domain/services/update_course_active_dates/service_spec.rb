require 'rails_helper'

RSpec.describe Services::UpdateCourseActiveDates::Service, type: :service do
  let(:service)               { described_class.new }

  let(:given_course_uuid)     { SecureRandom.uuid }
  let(:given_sequence_number) { rand(10) }
  let(:given_starts_at)       { Time.now.yesterday.utc.iso8601(6) }
  let(:given_ends_at)         { Time.now.tomorrow.utc.iso8601(6) }

  let(:action)                do
    service.process(
      course_uuid: given_course_uuid,
      sequence_number: given_sequence_number,
      starts_at: given_starts_at,
      ends_at: given_ends_at
    )
  end

  context "when a previously existing course_uuid and sequence_number combination is given" do
    before do
      FactoryGirl.create :course_active_date, course_uuid: given_course_uuid,
                                              sequence_number: given_sequence_number
    end

    it "a CourseActiveDate is NOT created" do
      expect{action}.not_to change{CourseActiveDate.count}
    end

    it "the course_uuid is returned" do
      expect(action.fetch(:updated_course_uuid)).to eq given_course_uuid
    end
  end

  context "when a previously non-existing course_uuid and sequence_number combination is given" do
    it "a CourseActiveDate is created with the correct attributes" do
      expect{action}.to change{CourseActiveDate.count}.by(1)
      course_active_date = CourseActiveDate.find_by(course_uuid: given_course_uuid,
                                                    sequence_number: given_sequence_number)
      expect(course_active_date.starts_at).to eq given_starts_at
      expect(course_active_date.ends_at).to eq given_ends_at
    end

    it "the course_uuid is returned" do
      expect(action.fetch(:updated_course_uuid)).to eq given_course_uuid
    end
  end
end
