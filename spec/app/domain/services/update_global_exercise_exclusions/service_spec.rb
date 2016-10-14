require 'rails_helper'

RSpec.describe Services::UpdateGlobalExerciseExclusions::Service do
  let(:service) { Services::UpdateGlobalExerciseExclusions::Service.new }

  let(:action) { service.process(
    update_uuid:        given_update_uuid,
    sequence_number: given_sequence_number,
    exclusions: given_exclusions
  ) }

  let(:given_exclusions) {
    (given_specific_version_exclusions + given_any_version_exclusions).shuffle
  }

  let(:given_specific_version_exclusions) {
    (number_of_exclusions - given_any_version_exclusions.length).times.map{
      exercise_uuid = SecureRandom.uuid.to_s

      given_exclusion_uuids.push(exercise_uuid)
      { 'exercise_uuid' => exercise_uuid }
    }
  }

  let(:given_any_version_exclusions) {
    Kernel::rand(number_of_exclusions).times.map{
      exercise_group_uuid = SecureRandom.uuid.to_s

      given_exclusion_uuids.push(exercise_group_uuid)
      { 'exercise_group_uuid' => exercise_group_uuid }
    }
  }

  let(:given_update_uuid)     { SecureRandom.uuid.to_s }
  let(:given_sequence_number) { Kernel::rand(10) }
  let(:number_of_exclusions)  { 10 }
  let(:given_exclusion_uuids) { [] }

  context "when excluded exercises are given" do
    it "the given number of GlobalExerciseExclusion is created" do
      expect{action}.to change{GlobalExerciseExclusion.count}.by(number_of_exclusions)
    end

    it "the number of excluded exercises returned is the given number of exclusions" do
      expect(action.fetch(:exercise_exclusions).length).to eq(number_of_exclusions)
    end

    it "the excluded uuids returned matches the given exclusions" do
      returned_excluded_uuids = action.fetch(:exercise_exclusions).map{ |exercise|
        exercise.fetch(:excluded_uuid)
      }
      expect(returned_excluded_uuids).to match_array(given_exclusion_uuids)
    end
  end

end
