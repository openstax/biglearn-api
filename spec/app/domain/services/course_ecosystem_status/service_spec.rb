require 'rails_helper'

RSpec.describe Services::CourseEcosystemStatus::Service, type: :service do
  let(:service)            { described_class.new }

  let(:given_request_uuid) { SecureRandom.uuid }
  let(:given_course_uuid)  { SecureRandom.uuid }
  let(:given_course_uuids) { [ given_course_uuid ] }

  let(:action)             do
    service.process(request_uuid: given_request_uuid, course_uuids: given_course_uuids)
  end

  context "when a non-existing Course uuid is given" do
    it "the course_uuid is returned with course_is_known: false" do
      course_status = action.fetch(:course_statuses).first
      expect(course_status.fetch(:course_uuid)).to eq given_course_uuid
      expect(course_status.fetch(:course_is_known)).to eq false
      expect(course_status.fetch(:current_ecosystem_preparation_uuid)).to be_nil

      current_ecosystem_status = course_status.fetch(:current_ecosystem_status)
      expect(current_ecosystem_status.fetch(:ecosystem_uuid)).to be_nil
      expect(current_ecosystem_status.fetch(:ecosystem_is_known)).to eq false
      expect(current_ecosystem_status.fetch(:ecosystem_is_prepared)).to eq false
      expect(current_ecosystem_status.fetch(:precompute_is_complete)).to eq false

      next_ecosystem_status = course_status.fetch(:next_ecosystem_status)
      expect(next_ecosystem_status.fetch(:ecosystem_uuid)).to be_nil
      expect(next_ecosystem_status.fetch(:ecosystem_is_known)).to eq false
      expect(next_ecosystem_status.fetch(:ecosystem_is_prepared)).to eq false
      expect(next_ecosystem_status.fetch(:precompute_is_complete)).to eq false
    end
  end

  context "when an existing Course uuid is given" do
    let!(:course) { FactoryGirl.create :course, uuid: given_course_uuid }

    context "and the next ecosystem is unknown" do
      it "the course_uuid is returned with the current ecosystem information" do
        course_status = action.fetch(:course_statuses).first
        expect(course_status.fetch(:course_uuid)).to eq given_course_uuid
        expect(course_status.fetch(:course_is_known)).to eq true
        expect(course_status.fetch(:current_ecosystem_preparation_uuid)).to be_nil

        current_ecosystem_status = course_status.fetch(:current_ecosystem_status)
        expect(current_ecosystem_status.fetch(:ecosystem_uuid)).to eq course.ecosystem_uuid
        expect(current_ecosystem_status.fetch(:ecosystem_is_known)).to eq true
        expect(current_ecosystem_status.fetch(:ecosystem_is_prepared)).to eq false
        expect(current_ecosystem_status.fetch(:precompute_is_complete)).to eq false

        next_ecosystem_status = course_status.fetch(:next_ecosystem_status)
        expect(next_ecosystem_status.fetch(:ecosystem_uuid)).to be_nil
        expect(next_ecosystem_status.fetch(:ecosystem_is_known)).to eq false
        expect(next_ecosystem_status.fetch(:ecosystem_is_prepared)).to eq false
        expect(next_ecosystem_status.fetch(:precompute_is_complete)).to eq false
      end
    end

    context "and the next ecosystem is prepared" do
      let!(:preparation) { FactoryGirl.create :ecosystem_preparation, course: course }

      it "the course_uuid is returned with the current and next ecosystem information" do
        course_status = action.fetch(:course_statuses).first
        expect(course_status.fetch(:course_uuid)).to eq given_course_uuid
        expect(course_status.fetch(:course_is_known)).to eq true
        expect(course_status.fetch(:current_ecosystem_preparation_uuid)).to eq preparation.uuid

        current_ecosystem_status = course_status.fetch(:current_ecosystem_status)
        expect(current_ecosystem_status.fetch(:ecosystem_uuid)).to eq course.ecosystem_uuid
        expect(current_ecosystem_status.fetch(:ecosystem_is_known)).to eq true
        expect(current_ecosystem_status.fetch(:ecosystem_is_prepared)).to eq false
        expect(current_ecosystem_status.fetch(:precompute_is_complete)).to eq false

        next_ecosystem_status = course_status.fetch(:next_ecosystem_status)
        expect(next_ecosystem_status.fetch(:ecosystem_uuid)).to eq preparation.ecosystem_uuid
        expect(next_ecosystem_status.fetch(:ecosystem_is_known)).to eq true
        expect(next_ecosystem_status.fetch(:ecosystem_is_prepared)).to eq true
        expect(next_ecosystem_status.fetch(:precompute_is_complete)).to eq false
      end
    end
  end
end
