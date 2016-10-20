require 'rails_helper'

RSpec.describe Services::UpdateGlobalExerciseExclusions::Service do

  let(:service) { Services::UpdateGlobalExerciseExclusions::Service.new }

  let(:action) { service.process(
    update_uuid:      given_update_uuid,
    sequence_number:  given_sequence_number,
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

  let(:number_of_exclusions_none)   { 0 }
  let(:number_of_exclusions_some)   { 10 }
  let(:number_of_exclusions_many)   { 100 }

  context "when a previously existing request is given" do
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

  context "when a previously non-existing request is given" do
    context "with no exclusions" do
      let(:number_of_exclusions)  {
        number_of_exclusions_none
      }

      it "the given number of GlobalExerciseExclusion is created" do
        expect{action}.to change{GlobalExerciseExclusion.count}.by(number_of_exclusions)
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

      it "the given number of GlobalExerciseExclusion is created" do
        expect{action}.to change{GlobalExerciseExclusion.count}.by(number_of_exclusions)
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

      it "the given number of GlobalExerciseExclusion is created" do
        expect{action}.to change{GlobalExerciseExclusion.count}.by(number_of_exclusions)
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
