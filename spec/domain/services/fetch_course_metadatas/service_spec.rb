require 'rails_helper'

RSpec.describe Services::FetchCourseMetadatas::Service, type: :service do
  let(:service)              { described_class.new }
  let(:action)               { service.process() }

  context "when there are no courses" do
    it "returns an empty array" do
      expect(action.fetch(:course_responses)).to eq([])
    end
  end

  context "when there are courses" do
    let(:courses_count)      { rand(10) + 1 }

    let!(:courses)           do
      FactoryGirl.create_list(:course_event, courses_count, {
        type: :create_course,
        sequence_number: 0,
        data: {
          ecosystem_uuid: SecureRandom.uuid
        }
      })
    end

    let(:expected_responses) do
      courses.map do |course|
        {
          uuid: course[:course_uuid],
          initial_ecosystem_uuid: course[:data].deep_symbolize_keys.fetch(:ecosystem_uuid)
        }
      end
    end

    it "all course uuids are returned in hashes" do
      expect(action.fetch(:course_responses)).to match_array expected_responses
    end
  end
end
