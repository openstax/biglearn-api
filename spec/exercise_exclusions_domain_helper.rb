module ExerciseExclusionsHelper

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
      :exclusions   =>  given_exclusions,
      :uuids        =>  given_exclusion_uuids,
    }
  end

  RSpec.shared_examples "Exercise exclusions: given_exclusions" do
    let(:given_exclusions) {
      generate_exclusions(number_of_exclusions)
    }
  end

  RSpec.shared_examples "Exercise exclusions: given_some_exclusions" do
    let(:given_some_exclusions) {
      generate_exclusions(number_of_exclusions_some)
    }
  end

  RSpec.shared_examples "Exercise exclusions: test creation and return" do |model|

    it "the given number of #{model.name} is created" do
      expect{action}.to change{model.count}.by(number_of_exclusions)
    end

    it "the excluded uuids returned matches the given exclusions" do
      returned_excluded_uuids = action.fetch(:exercise_exclusions).map{ |exercise|
        exercise.fetch(:excluded_uuid)
      }

      expect(returned_excluded_uuids).to match_array(given_exclusions.fetch(:uuids))
    end
  end

  RSpec.shared_examples "Exercise exclusions service" do |model|
    context "with no exclusions" do
      let(:number_of_exclusions) {
        number_of_exclusions_none
      }

      include_examples "Exercise exclusions: test creation and return", model
    end

    context "with some exclusions" do
      let(:number_of_exclusions) {
        number_of_exclusions_some
      }

      include_examples "Exercise exclusions: test creation and return", model
    end

    context "with many exclusions" do
      let(:number_of_exclusions) {
        number_of_exclusions_many
      }

      include_examples "Exercise exclusions: test creation and return", model
    end
  end

end