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

  it "an EcosystemMap is NOT created if it already exists" do
    FactoryGirl.create :ecosystem_map, given_ecosystem_map
    expect{action}.not_to change{EcosystemMap.count}
  end

  it "an EcosystemMap is created with the correct attributes if it does not yet exist" do
    expect{action}.to change{EcosystemMap.count}.by(1)
    ecosystem_map = EcosystemMap.find_by(
      from_ecosystem_uuid: given_course_ecosystem_uuid,
      to_ecosystem_uuid: given_next_ecosystem_uuid
    )
    expect(ecosystem_map.cnx_pagemodule_mappings).to eq given_cnx_pagemodule_mappings
    expect(ecosystem_map.exercise_mappings).to eq given_exercise_mappings
  end

  it "an EcosystemPreparation is created with the correct attributes" do
    expect{action}.to change{EcosystemPreparation.count}.by(1)
    ecosystem_preparation = EcosystemPreparation.find_by(uuid: given_preparation_uuid)
    expect(ecosystem_preparation.course_uuid).to eq given_course_uuid
    expect(ecosystem_preparation.sequence_number).to eq given_sequence_number
    expect(ecosystem_preparation.ecosystem_uuid).to eq given_next_ecosystem_uuid
  end

  it "status: 'accepted' is returned" do
    expect(action.fetch(:status)).to eq('accepted')
  end
end
