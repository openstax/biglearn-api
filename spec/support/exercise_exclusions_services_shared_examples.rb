module ExerciseExclusionsServicesSharedExamples
  SOME_EXCLUSIONS_NUMBER = 10
  MANY_EXCLUSIONS_NUMBER = 100

  RSpec.shared_examples "update exercise exclusions services" do |model, action_proc, attr_proc|
    let(:given_request_uuid)                  { SecureRandom.uuid }
    let(:given_sequence_number)               { rand(10) + 1 }
    let(:generated_exclusions)                { generate_exclusions(number_of_exclusions) }
    let(:given_exclusions)                    { generated_exclusions.fetch(:exclusions) }
    let(:given_excluded_exercise_uuids)       do
      generated_exclusions.fetch(:excluded_exercise_uuids)
    end
    let(:given_excluded_exercise_group_uuids) do
      generated_exclusions.fetch(:excluded_exercise_group_uuids)
    end

    context "with no preexisting exclusions" do
      include_examples "update exercise exclusions internal 1", model, action_proc, attr_proc
    end

    context "with one preexisting exclusion" do
      before { save_preexisting_exclusions(action_proc, generate_exclusions(1)) }

      include_examples "update exercise exclusions internal 1", model, action_proc, attr_proc
    end

    context "with some preexisting exclusions" do
      before do
        save_preexisting_exclusions(action_proc, generate_exclusions(SOME_EXCLUSIONS_NUMBER))
      end

      include_examples "update exercise exclusions internal 1", model, action_proc, attr_proc
    end

    context "with many preexisting exclusions" do
      before do
        save_preexisting_exclusions(action_proc, generate_exclusions(MANY_EXCLUSIONS_NUMBER))
      end

      include_examples "update exercise exclusions internal 1", model, action_proc, attr_proc
    end
  end

  protected

  RSpec.shared_examples "update exercise exclusions internal 1" do |model, action_proc, attr_proc|
    context "with no exclusions" do
      let(:number_of_exclusions) { 0 }

      include_examples "update exercise exclusions internal 2", model, action_proc, attr_proc
    end

    context "with one exclusion" do
      let(:number_of_exclusions) { 1 }

      include_examples "update exercise exclusions internal 2", model, action_proc, attr_proc
    end

    context "with some exclusions" do
      let(:number_of_exclusions) { SOME_EXCLUSIONS_NUMBER }

      include_examples "update exercise exclusions internal 2", model, action_proc, attr_proc
    end

    context "with many exclusions" do
      let(:number_of_exclusions) { MANY_EXCLUSIONS_NUMBER }

      include_examples "update exercise exclusions internal 2", model, action_proc, attr_proc
    end
  end

  RSpec.shared_examples "update exercise exclusions internal 2" do |model, action_proc, attr_proc|
    let(:action) do
      action_proc.call(
        request_uuid: given_request_uuid,
        sequence_number: given_sequence_number,
        exclusions: given_exclusions
      )
    end

    it "the #{model.name} is created with the correct attributes" do
      expect{action}.to change{model.count}.by(1)

      new_model = model.order(:created_at).last
      expect(new_model.uuid).to eq given_request_uuid
      expect(new_model.sequence_number).to eq given_sequence_number

      expect(new_model.excluded_exercise_uuids).to eq given_excluded_exercise_uuids
      expect(new_model.excluded_exercise_group_uuids).to eq given_excluded_exercise_group_uuids

      expect(attr_proc.call(new_model)).not_to(eq(false)) unless attr_proc.nil?
    end

    it "status: 'success' is returned" do
      expect(action.fetch(:status)).to eq 'success'
    end
  end

  def generate_exclusions(number_of_exclusions)
    given_exclusion_uuids = []

    number_of_any_version_exclusions = rand(number_of_exclusions).floor
    given_any_version_exclusions = number_of_any_version_exclusions.times.map do
      exercise_group_uuid = SecureRandom.uuid

      given_exclusion_uuids << exercise_group_uuid

      { exercise_group_uuid: exercise_group_uuid }
    end

    number_of_specific_version_exclusions = number_of_exclusions - number_of_any_version_exclusions
    given_specific_version_exclusions = number_of_specific_version_exclusions.times.map do
      exercise_uuid = SecureRandom.uuid

      given_exclusion_uuids << exercise_uuid

      { exercise_uuid: exercise_uuid }
    end

    given_exclusions = (given_specific_version_exclusions + given_any_version_exclusions).shuffle
    given_excluded_exercise_uuids = given_exclusions.map do |exclusion_hash|
      exclusion_hash[:exercise_uuid]
    end.compact
    given_excluded_exercise_group_uuids = given_exclusions.map do |exclusion_hash|
      exclusion_hash[:exercise_group_uuid]
    end.compact

    {
      exclusions: given_exclusions,
      excluded_exercise_uuids: given_excluded_exercise_uuids,
      excluded_exercise_group_uuids: given_excluded_exercise_group_uuids
    }
  end

  def save_preexisting_exclusions(action_proc, generated_exclusions)
    action_proc.call(
      request_uuid: SecureRandom.uuid,
      sequence_number: 0,
      exclusions: generated_exclusions.fetch(:exclusions)
    )
  end

end
