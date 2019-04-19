require 'rails_helper'

RSpec.describe Services::FetchCourseMetadatas::Service, type: :service do
  let(:service)                 { described_class.new }
  let(:given_max_num_metadatas) { 1000 }
  let(:action)                  do
    service.process(
      metadata_sequence_number_offset: given_metadata_sequence_number_offset,
      max_num_metadatas: given_max_num_metadatas
    )
  end

  context "when there are no courses" do
    let(:given_metadata_sequence_number_offset) { 0 }

    it "returns an empty array" do
      expect(action.fetch(:course_responses)).to eq([])
    end
  end

  context "when there are courses" do
    let(:courses_count)                         { rand(10) + 2            }
    let(:given_metadata_sequence_number_offset) { rand(courses_count - 1) }

    let!(:courses)                              do
      FactoryGirl.create_list(:course, courses_count).tap do |courses|
        courses.last.update_attribute :initial_ecosystem_uuid, nil
      end
    end

    let(:expected_responses) do
      courses[0..-2].select do |course|
        course.metadata_sequence_number >= given_metadata_sequence_number_offset
      end.map do |course|
        {
          uuid: course.uuid,
          initial_ecosystem_uuid: course.initial_ecosystem_uuid,
          metadata_sequence_number: course.metadata_sequence_number
        }
      end
    end

    it "newer course uuids are returned in hashes" do
      expect(action.fetch(:course_responses)).to match_array expected_responses
    end
  end
end
