require 'rails_helper'

RSpec.describe Services::FetchEcosystemMetadatas::Service, type: :service do
  let(:service)                 { described_class.new }
  let(:given_max_num_metadatas) { 1000 }
  let(:action)                  do
    service.process(
      metadata_sequence_number_offset: given_metadata_sequence_number_offset,
      max_num_metadatas: given_max_num_metadatas
    )
  end

  context "when there are no ecosystems" do
    let(:given_metadata_sequence_number_offset) { 0 }

    it "returns an empty array" do
      expect(action.fetch(:ecosystem_responses)).to eq([])
    end
  end

  context "when there are ecosystems" do
    let(:ecosystems_count)                      { rand(10) + 1           }
    let(:given_metadata_sequence_number_offset) { rand(ecosystems_count) }

    let!(:ecosystems)        { FactoryGirl.create_list :ecosystem, ecosystems_count }

    let(:expected_responses) do
      ecosystems.select do |ecosystem|
        ecosystem.metadata_sequence_number >= given_metadata_sequence_number_offset
      end.map do |ecosystem|
        { uuid: ecosystem.uuid, metadata_sequence_number: ecosystem.metadata_sequence_number }
      end
    end

    it "newer ecosystem uuids are returned in hashes" do
      expect(action.fetch(:ecosystem_responses)).to match_array expected_responses
    end
  end
end
