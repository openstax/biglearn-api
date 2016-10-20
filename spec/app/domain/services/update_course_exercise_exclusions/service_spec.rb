require 'rails_helper'

RSpec.describe Services::UpdateCourseExerciseExclusions::Service do

  let(:service) { Services::UpdateCourseExerciseExclusions::Service.new }

  let(:action) { service.process(
    update_uuid:      given_update_uuid,
    sequence_number:  given_sequence_number,
    course_uuid:      given_course_uuid,
    exclusions:       given_exclusions.exclusions
  ) }

  let(:given_exclusions) {
    number_of_exclusions_any = Kernel::rand(number_of_exclusions).floor
    number_of_exclusions_specific = number_of_exclusions - number_of_exclusions_any

    build_stubbed(:exercise_exclusions, exclusions_count: number_of_exclusions,
                              exclusions_any_count: number_of_exclusions_any,
                              exclusions_specific_count: number_of_exclusions_specific)
  }

  let(:action_repeat) { service.process(
    update_uuid:      given_update_uuid,
    sequence_number:  given_sequence_number,
    course_uuid:      given_course_uuid,
    exclusions:       given_some_exclusions.exclusions
  ) }

  let(:given_some_exclusions) {
    number_of_exclusions_any = Kernel::rand(number_of_exclusions_some)
    number_of_exclusions_specific = number_of_exclusions_some - number_of_exclusions_any

    build_stubbed(:exercise_exclusions, exclusions_count: number_of_exclusions_some,
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
      context "with no exclusions" do
        let(:number_of_exclusions)  {
          number_of_exclusions_none
        }

        it "the given number of CourseExerciseExclusion is created" do
          expect{action}.to change{CourseExerciseExclusion.count}.by(number_of_exclusions)
        end

        it "the excluded uuids returned matches the given exclusions" do
          returned_excluded_uuids = action.fetch(:exercise_exclusions).map{ |exercise|
            exercise.fetch(:excluded_uuid)
          }
          expect(returned_excluded_uuids).to match_array(given_exclusions.uuids)
        end
      end

      context "with some exclusions" do
        let(:number_of_exclusions)  {
          number_of_exclusions_some
        }

        it "the given number of CourseExerciseExclusion is created" do
          expect{action}.to change{CourseExerciseExclusion.count}.by(number_of_exclusions)
        end

        it "the excluded uuids returned matches the given exclusions" do
          returned_excluded_uuids = action.fetch(:exercise_exclusions).map{ |exercise|
            exercise.fetch(:excluded_uuid)
          }
          expect(returned_excluded_uuids).to match_array(given_exclusions.uuids)
        end
      end

      context "with many exclusions" do
        let(:number_of_exclusions)  {
          number_of_exclusions_many
        }

        it "the given number of CourseExerciseExclusion is created" do
          expect{action}.to change{CourseExerciseExclusion.count}.by(number_of_exclusions)
        end

        it "the excluded uuids returned matches the given exclusions" do
          returned_excluded_uuids = action.fetch(:exercise_exclusions).map{ |exercise|
            exercise.fetch(:excluded_uuid)
          }
          expect(returned_excluded_uuids).to match_array(given_exclusions.uuids)
        end
      end
    end
  end
end
