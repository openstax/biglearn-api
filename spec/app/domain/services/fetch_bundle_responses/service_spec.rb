require 'rails_helper'

RSpec.describe Services::FetchResponseBundles::Service do
  let(:service) { Services::FetchResponseBundles::Service.new }

  let(:action) {
    service.process(
      max_bundles_to_return:   given_max_bundles_to_return,
      bundle_uuids_to_confirm: given_bundle_uuids_to_confirm,
      receiver_uuid:           given_receiver_uuid,
      partition_count:         given_partition_count,
      partition_modulo:        given_partition_modulo,
    )
  }

  let(:given_max_bundles_to_return)   { 10 }
  let(:given_bundle_uuids_to_confirm) { [] }
  let(:given_receiver_uuid)           { SecureRandom.uuid.to_s }
  let(:given_partition_count)         { 6 }
  let(:given_partition_modulo)        { 1 }

  let(:responses) {
    10.times.map do
      create(:response)
    end
  }

  let(:target_confirmed_bundle_uuids) { [ SecureRandom.uuid.to_s ] }
  let(:target_responses)              { responses.values_at(1,3,5,7,9) }
  let(:target_model_uuids)            { target_responses.map(&:uuid) }
  let(:target_bundle_uuids)           { [ SecureRandom.uuid.to_s ] }

  let(:bundle_manager) {
    dbl = object_double(OpenStax::BundleManager::Manager.new(model: Response))
    allow(dbl).to receive(:confirm)
              .with(
                receiver_uuid:           given_receiver_uuid,
                bundle_uuids_to_confirm: given_bundle_uuids_to_confirm)
              .and_return(target_confirmed_bundle_uuids)
    allow(dbl).to receive(:fetch)
              .with(
                goal_records_to_return: anything,
                max_bundles_to_process: given_max_bundles_to_return,
                receiver_uuid:          given_receiver_uuid,
                partition_count:        given_partition_count,
                partition_modulo:       given_partition_modulo
              ).and_return(
                { model_uuids:   target_model_uuids,
                  bundle_uuids:  target_bundle_uuids, }
              )
    dbl
  }

  before(:each) do
    allow(OpenStax::BundleManager::Manager).to receive(:new).and_return(bundle_manager)
  end

  context "bundle confirmation:" do
    it "it delegates to its BundleManager with the correct parameters" do
      action
      expect(bundle_manager).to have_received(:confirm).with(
        receiver_uuid:           given_receiver_uuid,
        bundle_uuids_to_confirm: given_bundle_uuids_to_confirm
      )
    end
    it "returns the BundleManager's confirmed bundle uuids" do
      expect(action.fetch(:confirmed_bundle_uuids)).to match_array(target_confirmed_bundle_uuids)
    end
  end

  context "fetching Response data:" do
    it "it delegates to its BundleManager with the correct parameters" do
      action
      expect(bundle_manager).to have_received(:fetch).with(
        goal_records_to_return:  anything,
        max_bundles_to_process:  given_max_bundles_to_return,
        receiver_uuid:           given_receiver_uuid,
        partition_count:         given_partition_count,
        partition_modulo:        given_partition_modulo,
      )
    end
    it "returns the Response data for the uuids returned by the BundleManager" do
      returned_response_data = action.fetch(:response_data)

      aggregate_failures "response data checks" do
        expect(target_responses).to_not be_empty
        expect(returned_response_data.count).to eq(target_responses.count)
        returned_response_data.zip(target_responses).each do |response_data, target_response|
          expect(target_response.uuid).to           eq(response_data.fetch(:response_uuid))
          expect(target_response.trial_uuid).to     eq(response_data.fetch(:trial_uuid))
          expect(target_response.trial_sequence).to eq(response_data.fetch(:trial_sequence))
          expect(target_response.learner_uuid).to   eq(response_data.fetch(:learner_uuid))
          expect(target_response.question_uuid).to  eq(response_data.fetch(:question_uuid))
          expect(target_response.is_correct).to     eq(response_data.fetch(:is_correct))
          expect(target_response.responded_at).to   be_within(1e-6).of(Chronic.parse(response_data.fetch(:responded_at)))
        end
      end
    end
    it "returns the BundleManager's bundle uuids" do
      expect(action.fetch(:bundle_uuids)).to match_array(target_bundle_uuids)
    end
  end
end
