module ExerciseExclusionsServicesSharedExamples
  SOME_EXCLUSIONS_NUMBER = 10
  MANY_EXCLUSIONS_NUMBER = 100

  RSpec.shared_examples "update exercise exclusions services" do |type|
    let(:service)               { described_class.new }

    let(:given_request_uuid)    { SecureRandom.uuid }
    let(:given_course_uuid)     { SecureRandom.uuid }
    let(:given_sequence_number) { rand(10) + 1 }
    let(:given_exclusions)      { generate_exclusions(number_of_exclusions) }
    let(:given_updated_at)      { Time.current.iso8601(6) }

    let(:action)                do
      service.process(
        request_uuid: given_request_uuid,
        course_uuid: given_course_uuid,
        sequence_number: given_sequence_number,
        exclusions: given_exclusions,
        updated_at: given_updated_at
      )
    end

    context "with no preexisting exclusions" do
      include_examples "update exercise exclusions internal 1", type
    end

    context "with one preexisting exclusion" do
      before { save_preexisting_exclusions(type, given_course_uuid, generate_exclusions(1)) }

      include_examples "update exercise exclusions internal 1", type
    end

    context "with some preexisting exclusions" do
      before do
        save_preexisting_exclusions(
          type, given_course_uuid, generate_exclusions(SOME_EXCLUSIONS_NUMBER)
        )
      end

      include_examples "update exercise exclusions internal 1", type
    end

    context "with many preexisting exclusions" do
      before do
        save_preexisting_exclusions(
          type, given_course_uuid, generate_exclusions(MANY_EXCLUSIONS_NUMBER)
        )
      end

      include_examples "update exercise exclusions internal 1", type
    end
  end

  protected

  RSpec.shared_examples "update exercise exclusions internal 1" do |type|
    context "with no exclusions" do
      let(:number_of_exclusions) { 0 }

      include_examples "update exercise exclusions internal 2", type
    end

    context "with one exclusion" do
      let(:number_of_exclusions) { 1 }

      include_examples "update exercise exclusions internal 2", type
    end

    context "with some exclusions" do
      let(:number_of_exclusions) { SOME_EXCLUSIONS_NUMBER }

      include_examples "update exercise exclusions internal 2", type
    end

    context "with many exclusions" do
      let(:number_of_exclusions) { MANY_EXCLUSIONS_NUMBER }

      include_examples "update exercise exclusions internal 2", type
    end
  end

  RSpec.shared_examples "update exercise exclusions internal 2" do |type|
    it "the CourseEvent is created with the correct attributes" do
      expect{action}.to change{CourseEvent.count}.by(1)

      new_event = CourseEvent.find_by(uuid: given_request_uuid)
      expect(new_event.course_uuid).to eq given_course_uuid
      expect(new_event.sequence_number).to eq given_sequence_number
      expect(new_event.data.deep_symbolize_keys.fetch(:exclusions)).to eq given_exclusions
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

    (given_specific_version_exclusions + given_any_version_exclusions).shuffle
  end

  def save_preexisting_exclusions(type, course_uuid, generated_exclusions)
    request_uuid = SecureRandom.uuid

    CourseEvent.append(
      uuid: request_uuid,
      type: type,
      course_uuid: course_uuid,
      sequence_number: 0,
      data: {
        request_uuid: request_uuid,
        exclusions: generated_exclusions
      }
    )
  end

end
