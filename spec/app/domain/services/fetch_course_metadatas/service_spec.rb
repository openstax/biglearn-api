require 'rails_helper'

RSpec.describe Services::FetchCourseMetadatas::Service, type: :service do
  let(:service)                   { described_class.new }
  let(:action)                    { service.process() }

  context "when there are no courses" do
    it "returns an empty array" do
      expect(action.fetch(:course_responses)).to eq([])
    end
  end

  context "when there are courses" do
    let(:courses_count)           { rand(10) + 1 }

    let!(:courses) do
      FactoryGirl.create_list :course, courses_count
    end

    it "all course uuids are returned in hashes" do
      expect(action.fetch(:course_responses)).to eq(courses.map{ |course| {uuid: course[:uuid]} })
    end
  end
end
