require 'rails_helper'

RSpec.describe Services::PrepareCourseEcosystem::Service, type: :service do
  let(:service)                       { described_class.new }

  let(:given_preparation_uuid)        { SecureRandom.uuid }
  let(:given_course_uuid)             { SecureRandom.uuid }
  let(:given_course_ecosystem_uuid)   { SecureRandom.uuid }
  let(:given_sequence_number)         { rand(10) }
  let(:given_next_ecosystem_uuid)     { SecureRandom.uuid }
  let(:given_cnx_pagemodule_mappings) { [] }
  let(:given_exercise_mappings)       { [] }
  let(:given_ecosystem_map)           do
    {
      from_ecosystem_uuid: given_course_ecosystem_uuid,
      to_ecosystem_uuid: given_next_ecosystem_uuid,
      cnx_pagemodule_mappings: given_cnx_pagemodule_mappings,
      exercise_mappings: given_exercise_mappings
    }
  end

  let(:action) do
    service.process(
      preparation_uuid: given_preparation_uuid,
      course_uuid: given_course_uuid,
      sequence_number: given_sequence_number,
      next_ecosystem_uuid: given_next_ecosystem_uuid,
      ecosystem_map: given_ecosystem_map
    )
  end

  context "when a previously-existing preparation_uuid is given" do
    before do
      FactoryGirl.create :course_event, uuid: given_preparation_uuid
    end

    it "a CourseEvent is NOT created" do
      expect{action}.not_to change{CourseEvent.count}
    end

    it "status: 'accepted' is returned" do
      expect(action.fetch(:status)).to eq('accepted')
    end
  end

  context "when a previously non-existing course_uuid and sequence_number combination is given" do
    it "a CourseEvent is created with the correct attributes" do
      expect{action}.to change{CourseEvent.count}.by(1)
      ecosystem_preparation = CourseEvent.find_by(uuid: given_preparation_uuid)
      expect(ecosystem_preparation.course_uuid).to eq given_course_uuid
      expect(ecosystem_preparation.sequence_number).to eq given_sequence_number
      data = ecosystem_preparation.data.deep_symbolize_keys
      expect(data[:ecosystem_uuid]).to eq given_next_ecosystem_uuid
      expect(data[:ecosystem_map]).to eq given_ecosystem_map
    end

    it "status: 'accepted' is returned" do
      expect(action.fetch(:status)).to eq('accepted')
    end
  end
end
