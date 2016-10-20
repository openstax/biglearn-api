require 'rails_helper'

RSpec.describe Services::UpdateCourseExerciseExclusions::Service, type: :exercise_exclusions_service do

  let(:service) { Services::UpdateCourseExerciseExclusions::Service.new }

  let(:action) { service.process(
    update_uuid:      given_update_uuid,
    sequence_number:  given_sequence_number,
    course_uuid:      given_course_uuid,
    exclusions:       given_exclusions.fetch(:exclusions)
  ) }

  let(:action_repeat) { service.process(
    update_uuid:      given_update_uuid,
    sequence_number:  given_sequence_number,
    course_uuid:      given_course_uuid,
    exclusions:       given_some_exclusions.fetch(:exclusions)
  ) }

  let(:given_update_uuid)           { SecureRandom.uuid.to_s }
  let(:given_sequence_number)       { Kernel::rand(10) }
  let(:given_course_uuid)           { SecureRandom.uuid.to_s }

  let(:number_of_exclusions_none)   { 0 }
  let(:number_of_exclusions_some)   { 10 }
  let(:number_of_exclusions_many)   { 100 }

  include_examples "Exercise exclusions: given_exclusions"
  include_examples "Exercise exclusions: given_some_exclusions"

  context "when a previously non-existing Course uuid is given" do
    let(:number_of_exclusions)  {
      number_of_exclusions_some
    }

    it "raises error" do
      expect{action}.to raise_error(Errors::AppUnprocessableError)
    end
  end

  context "when previously existing Course uuid is given" do
    before(:each) do
      create(:course, uuid: given_course_uuid)
    end

    context "and previously existing request is given" do
      before(:each) do
        action_repeat
      end

      context "with no exclusions" do
        let(:number_of_exclusions)  {
          number_of_exclusions_none
        }

        it "raises error" do
          expect{action}.to raise_error(ActiveRecord::RecordNotUnique)
        end
      end

      context "with some exclusions" do
        let(:number_of_exclusions)  {
          number_of_exclusions_some
        }

        it "raises error" do
          expect{action}.to raise_error(ActiveRecord::RecordNotUnique)
        end
      end

      context "with many exclusions" do
        let(:number_of_exclusions)  {
          number_of_exclusions_many
        }

        it "raises error" do
          expect{action}.to raise_error(ActiveRecord::RecordNotUnique)
        end
      end
    end

    context "and previously non-existing request is given" do
      it_behaves_like "Exercise exclusions service", CourseExerciseExclusion
    end
  end
end
