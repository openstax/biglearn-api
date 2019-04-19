require 'rails_helper'

RSpec.describe Services::UpdateCourseActiveDates::Service, type: :service do
  let(:service)               { described_class.new }

  let(:given_request_uuid)    { SecureRandom.uuid }
  let(:given_course_uuid)     { SecureRandom.uuid }
  let(:given_sequence_number) { rand(10) }
  let(:given_starts_at)       { Time.current.yesterday.iso8601(6) }
  let(:given_ends_at)         { Time.current.tomorrow.iso8601(6)  }
  let(:given_updated_at)      { Time.current.iso8601(6)           }

  let(:action)                do
    service.process(
      request_uuid: given_request_uuid,
      course_uuid: given_course_uuid,
      sequence_number: given_sequence_number,
      starts_at: given_starts_at,
      ends_at: given_ends_at,
      updated_at: given_updated_at
    )
  end

  context "when a previously existing course_uuid and sequence_number combination is given" do
    before do
      FactoryGirl.create :course_event, course_uuid: given_course_uuid,
                                        sequence_number: given_sequence_number
    end

    it "a CourseEvent is NOT created and an error is returned" do
      expect{action}.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  context "when a previously non-existing course_uuid and sequence_number combination is given" do
    it "a CourseEvent is created with the correct attributes" do
      expect{action}.to change{ CourseEvent.count }.by(1)
      course_active_date = CourseEvent.find_by(course_uuid: given_course_uuid,
                                               sequence_number: given_sequence_number)
      data = course_active_date.data.deep_symbolize_keys
      expect(data.fetch(:starts_at)).to eq given_starts_at
      expect(data.fetch(:ends_at)).to eq given_ends_at
    end

    it "the course_uuid is returned" do
      expect(action.fetch(:updated_course_uuid)).to eq given_course_uuid
    end
  end
end
