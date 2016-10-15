require 'rails_helper'

RSpec.describe Services::UpdateGlobalExerciseExclusions::Service do

  def generate_exclusions(number_of_exclusions)
    given_exclusion_uuids = []

    given_any_version_exclusions = Kernel::rand(number_of_exclusions).floor.times.map{
      exercise_group_uuid = SecureRandom.uuid.to_s

      given_exclusion_uuids.push(exercise_group_uuid)
      { 'exercise_group_uuid' => exercise_group_uuid }
    }

    given_specific_version_exclusions = (number_of_exclusions - given_any_version_exclusions.length).times.map{
      exercise_uuid = SecureRandom.uuid.to_s

      given_exclusion_uuids.push(exercise_uuid)
      { 'exercise_uuid' => exercise_uuid }
    }

    given_exclusions = (given_specific_version_exclusions + given_any_version_exclusions).shuffle

    {
      :exclusions       =>  given_exclusions,
      :uuids  =>  given_exclusion_uuids,
    }
  end

  let(:service) { Services::UpdateGlobalExerciseExclusions::Service.new }

  let(:action_none) { service.process(
    update_uuid:      given_update_uuid,
    sequence_number:  given_sequence_number,
    exclusions:       given_none_exclusions.fetch(:exclusions)
  ) }

  let(:action_some) { service.process(
    update_uuid:      given_update_uuid,
    sequence_number:  given_sequence_number,
    exclusions:       given_some_exclusions.fetch(:exclusions)
  ) }

  let(:action_many) { service.process(
    update_uuid:      given_update_uuid,
    sequence_number:  given_sequence_number,
    exclusions:       given_many_exclusions.fetch(:exclusions)
  ) }

  let(:action_repeat) { service.process(
    update_uuid:      given_update_uuid,
    sequence_number:  given_sequence_number,
    exclusions:       given_some_exclusions.fetch(:exclusions)
  ) }

  let(:given_none_exclusions) {
    generate_exclusions(number_of_exclusions_none)
  }

  let(:given_some_exclusions) {
    generate_exclusions(number_of_exclusions_some)
  }

  let(:given_many_exclusions) {
    generate_exclusions(number_of_exclusions_many)
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

  context "when a previously non-existing request is given" do
    context "with no exclusions" do
      it "the given number of GlobalExerciseExclusion is created" do
        expect{action_none}.to change{GlobalExerciseExclusion.count}.by(number_of_exclusions_none)
      end

      it "the number of excluded exercises returned is the given number of exclusions" do
        expect(action_none.fetch(:exercise_exclusions).length).to eq(number_of_exclusions_none)
      end

      it "the excluded uuids returned matches the given exclusions" do
        returned_excluded_uuids = action_none.fetch(:exercise_exclusions).map{ |exercise|
          exercise.fetch(:excluded_uuid)
        }
        expect(returned_excluded_uuids).to match_array(given_none_exclusions.fetch(:uuids))
      end
    end

    context "with some exclusions" do
      it "the given number of GlobalExerciseExclusion is created" do
        expect{action_some}.to change{GlobalExerciseExclusion.count}.by(number_of_exclusions_some)
      end

      it "the number of excluded exercises returned is the given number of exclusions" do
        expect(action_some.fetch(:exercise_exclusions).length).to eq(number_of_exclusions_some)
      end

      it "the excluded uuids returned matches the given exclusions" do
        returned_excluded_uuids = action_some.fetch(:exercise_exclusions).map{ |exercise|
          exercise.fetch(:excluded_uuid)
        }
        expect(returned_excluded_uuids).to match_array(given_some_exclusions.fetch(:uuids))
      end
    end

    context "with many exclusions" do
      it "the given number of GlobalExerciseExclusion is created" do
        expect{action_many}.to change{GlobalExerciseExclusion.count}.by(number_of_exclusions_many)
      end

      it "the number of excluded exercises returned is the given number of exclusions" do
        expect(action_many.fetch(:exercise_exclusions).length).to eq(number_of_exclusions_many)
      end

      it "the excluded uuids returned matches the given exclusions" do
        returned_excluded_uuids = action_many.fetch(:exercise_exclusions).map{ |exercise|
          exercise.fetch(:excluded_uuid)
        }
        expect(returned_excluded_uuids).to match_array(given_many_exclusions.fetch(:uuids))
      end
    end
  end
end
