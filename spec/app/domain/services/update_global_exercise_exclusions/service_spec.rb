require 'rails_helper'

RSpec.describe Services::UpdateGlobalExerciseExclusions::Service, type: :exercise_exclusions_service do

  let(:service) { Services::UpdateGlobalExerciseExclusions::Service.new }

  let(:action) { service.process(
    update_uuid:      given_update_uuid,
    sequence_number:  given_sequence_number,
    exclusions:       given_exclusions.fetch(:exclusions)
  ) }

  let(:action_repeat) { service.process(
    update_uuid:      given_update_uuid,
    sequence_number:  given_sequence_number,
    exclusions:       given_some_exclusions.fetch(:exclusions)
  ) }

  let(:given_update_uuid)           { SecureRandom.uuid.to_s }
  let(:given_sequence_number)       { Kernel::rand(10) }

  let(:number_of_exclusions_none)   { 0 }
  let(:number_of_exclusions_some)   { 10 }
  let(:number_of_exclusions_many)   { 100 }

  include_examples "Exercise exclusions: given_exclusions"
  include_examples "Exercise exclusions: given_some_exclusions"

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
    it_behaves_like "Exercise exclusions service", GlobalExerciseExclusion
  end
end
