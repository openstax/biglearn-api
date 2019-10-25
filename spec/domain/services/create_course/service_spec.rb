require 'rails_helper'

RSpec.describe Services::CreateCourse::Service do
  let(:service)                       { described_class.new               }

  let(:given_course_uuid)    { SecureRandom.uuid                 }
  let(:given_ecosystem_uuid) { SecureRandom.uuid                 }
  let(:given_is_real_course) { [ true, false ].sample            }
  let(:given_starts_at)      { Time.current.iso8601(6)           }
  let(:given_ends_at)        { Time.current.tomorrow.iso8601(6)  }
  let(:given_created_at)     { Time.current.yesterday.iso8601(6) }

  let(:action)               do
    service.process(
      course_uuid: given_course_uuid,
      ecosystem_uuid: given_ecosystem_uuid,
      is_real_course: given_is_real_course,
      starts_at: given_starts_at,
      ends_at: given_ends_at,
      created_at: given_created_at
    )
  end

  context "and a previously-existing course_uuid is given" do
    before(:each) do
      FactoryBot.create(:course_event, uuid: given_course_uuid, type: :create_course)
    end

    it "a CourseEvent is NOT created" do
      expect{action}.to_not change{CourseEvent.count}
    end

    it "the course_uuid is returned" do
      expect(action.fetch(:created_course_uuid)).to eq(given_course_uuid)
    end
  end

  context "and a previously non-existing course_uuid is given" do
    it "a CourseEvent is created with the correct attributes" do
      expect{action}.to change{CourseEvent.count}.by(1)
      course = CourseEvent.find_by(uuid: given_course_uuid)
      data = course.data.deep_symbolize_keys
      expect(data.fetch(:ecosystem_uuid)).to eq given_ecosystem_uuid
      expect(data.fetch(:is_real_course)).to eq given_is_real_course
      expect(data.fetch(:starts_at)).to eq given_starts_at
      expect(data.fetch(:ends_at)).to eq given_ends_at
      expect(data.fetch(:created_at)).to eq given_created_at
    end

    it "the course_uuid is returned" do
      expect(action.fetch(:created_course_uuid)).to eq(given_course_uuid)
    end
  end
end
