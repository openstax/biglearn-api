require 'rails_helper'

RSpec.describe Services::UpdateCourseExerciseExclusions::Service do

  let(:service) { Services::UpdateCourseExerciseExclusions::Service.new }

  let(:action_none) { service.process(
    update_uuid:      given_update_uuid,
    sequence_number:  given_sequence_number,
    course_uuid:      given_course_uuid,
    exclusions:       given_none_exclusions.exclusions
  ) }

  let(:action_some) { service.process(
    update_uuid:      given_update_uuid,
    sequence_number:  given_sequence_number,
    course_uuid:      given_course_uuid,
    exclusions:       given_some_exclusions.exclusions
  ) }

  let(:action_many) { service.process(
    update_uuid:      given_update_uuid,
    sequence_number:  given_sequence_number,
    course_uuid:      given_course_uuid,
    exclusions:       given_many_exclusions.exclusions
  ) }

  let(:action_repeat) { service.process(
    update_uuid:      given_update_uuid,
    sequence_number:  given_sequence_number,
    course_uuid:      given_course_uuid,
    exclusions:       given_some_exclusions.exclusions
  ) }

  let(:given_none_exclusions) {
    build_stubbed(:exercise_exclusions, exclusions_count: number_of_exclusions_none,
                              exclusions_any_count: number_of_exclusions_none,
                              exclusions_specific_count: number_of_exclusions_none)
  }

  let(:given_some_exclusions) {
    number_of_exclusions_any = Kernel::rand(number_of_exclusions_some)
    number_of_exclusions_specific = number_of_exclusions_some - number_of_exclusions_any

    build_stubbed(:exercise_exclusions, exclusions_count: number_of_exclusions_some,
                              exclusions_any_count: number_of_exclusions_any,
                              exclusions_specific_count: number_of_exclusions_specific)
  }

  let(:given_many_exclusions) {
    number_of_exclusions_any = Kernel::rand(number_of_exclusions_many)
    number_of_exclusions_specific = number_of_exclusions_many - number_of_exclusions_any

    build_stubbed(:exercise_exclusions, exclusions_count: number_of_exclusions_many,
                              exclusions_any_count: number_of_exclusions_any,
                              exclusions_specific_count: number_of_exclusions_specific)
  }

  let(:given_update_uuid)           { SecureRandom.uuid.to_s }
  let(:given_sequence_number)       { Kernel::rand(10) }
  let(:given_course_uuid)           { SecureRandom.uuid.to_s }

  let(:number_of_exclusions_none)   { 0 }
  let(:number_of_exclusions_some)   { 10 }
  let(:number_of_exclusions_many)   { 100 }

  context "when a previously non-existing Course uuid is given" do
    it "raises error" do
      expect{action_some}.to raise_error(Errors::AppUnprocessableError)
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
        it "raises error" do
          expect{action_none}.to raise_error(ActiveRecord::RecordNotUnique)
        end
      end

      context "with some exclusions" do
        it "raises error" do
          expect{action_some}.to raise_error(ActiveRecord::RecordNotUnique)
        end
      end

      context "with many exclusions" do
        it "raises error" do
          expect{action_many}.to raise_error(ActiveRecord::RecordNotUnique)
        end
      end
    end

    context "and previously non-existing request is given" do
      context "with no exclusions" do
        it "the given number of CourseExerciseExclusion is created" do
          expect{action_none}.to change{CourseExerciseExclusion.count}.by(number_of_exclusions_none)
        end

        it "the excluded uuids returned matches the given exclusions" do
          returned_excluded_uuids = action_none.fetch(:exercise_exclusions).map{ |exercise|
            exercise.fetch(:excluded_uuid)
          }
          expect(returned_excluded_uuids).to match_array(given_none_exclusions.uuids)
        end
      end

      context "with some exclusions" do
        it "the given number of CourseExerciseExclusion is created" do
          expect{action_some}.to change{CourseExerciseExclusion.count}.by(number_of_exclusions_some)
        end

        it "the excluded uuids returned matches the given exclusions" do
          returned_excluded_uuids = action_some.fetch(:exercise_exclusions).map{ |exercise|
            exercise.fetch(:excluded_uuid)
          }
          expect(returned_excluded_uuids).to match_array(given_some_exclusions.uuids)
        end
      end

      context "with many exclusions" do
        it "the given number of CourseExerciseExclusion is created" do
          expect{action_many}.to change{CourseExerciseExclusion.count}.by(number_of_exclusions_many)
        end

        it "the excluded uuids returned matches the given exclusions" do
          returned_excluded_uuids = action_many.fetch(:exercise_exclusions).map{ |exercise|
            exercise.fetch(:excluded_uuid)
          }
          expect(returned_excluded_uuids).to match_array(given_many_exclusions.uuids)
        end
      end
    end
  end
end
