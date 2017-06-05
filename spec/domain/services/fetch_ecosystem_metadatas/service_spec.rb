require 'rails_helper'

RSpec.describe Services::FetchEcosystemMetadatas::Service, type: :service do
  let(:service)              { described_class.new }
  let(:action)               { service.process() }

  context "when there are no ecosystems" do
    it "returns an empty array" do
      expect(action.fetch(:ecosystem_responses)).to eq([])
    end
  end

  context "when there are ecosystems" do
    let(:ecosystems_count)   { rand(10) + 1 }

    let!(:ecosystems)        { FactoryGirl.create_list :ecosystem_event, ecosystems_count }

    let(:expected_responses) do
      ecosystems.map { |ecosystem| { uuid: ecosystem[:ecosystem_uuid] } }
    end

    it "all ecosystem uuids are returned in hashes" do
      expect(action.fetch(:ecosystem_responses)).to eq expected_responses
    end
  end
end