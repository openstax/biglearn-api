require 'rails_helper'

RSpec.describe "Openstax::BundleManager::Manager: fetching" do
  let(:manager) { Openstax::BundleManager::Manager.new(model: XTest1) }

  let(:action) {
    manager.fetch(
      goal_records_to_return: given_goal_records_to_return,
      max_bundles_to_process: given_max_bundles_to_process,
      receiver_uuid:          given_receiver_uuid,
      partition_count:        given_partition_count,
      partition_modulo:       given_partition_modulo,
    )
  }

  let(:given_goal_records_to_return) { 10 }
  let(:given_max_bundles_to_process) { 5 }
  let(:given_receiver_uuid)          { target_receiver_uuid }
  let(:given_partition_count)        { 5 }
  let(:given_partition_modulo)       { target_partition_modulo }

  let(:target_receiver_uuid)    { SecureRandom.uuid.to_s }
  let(:nontarget_receiver_uuid) { SecureRandom.uuid.to_s }

  let(:target_partition_modulo) { 3 }
  let(:target_partition_value) {
    begin
      value = Kernel::rand(10000)
    end while value % given_partition_count != target_partition_modulo
    value
  }
  let(:nontarget_partition_value) { target_partition_value + 1 }

  let(:tpv) { target_partition_value }
  let(:npv) { nontarget_partition_value }

  context "when there are no unbundled Bundle::Records and no unconfirmed Bundle::BundleRecords" do
    let!(:bundle_records) {
      [ create(:bundle_record, partition_value: npv),
        create(:bundle_record, partition_value: tpv),
        create(:bundle_record, partition_value: npv),
        create(:bundle_record, partition_value: tpv),
        create(:bundle_record, partition_value: npv), ]
    }

    let!(:bundle_record_bundles) {
      [ create(:bundle_record_bundle, for_bundle_records: bundle_records.values_at(1,3)), ]
    }

    let!(:bundle_record_confirmations) {
      bundle_record_bundles.map do |record_bundle|
        create(:bundle_record_confirmation, for_bundle: record_bundle, receiver_uuid: target_receiver_uuid)
      end
    }

    it "no Record uuids are returned" do
      expect(action.fetch(:model_uuids)).to be_empty
    end
    it "no Bundle::RecordBundle uuids are returned" do
      expect(action.fetch(:bundle_uuids)).to be_empty
    end
  end

  context "when there are unbundled Bundle::Records and unconfirmed Bundle::BundleRecords" do
    let!(:reference_time) { Time.now }

    let!(:bundle_records) {
      [ create(:bundle_record, partition_value: npv, created_at: reference_time -  0.seconds), ## 0
        create(:bundle_record, partition_value: npv, created_at: reference_time -  2.seconds),
        create(:bundle_record, partition_value: npv, created_at: reference_time -  4.seconds), ## 2
        create(:bundle_record, partition_value: tpv, created_at: reference_time -  6.seconds),
        create(:bundle_record, partition_value: npv, created_at: reference_time -  8.seconds), ## 4
        create(:bundle_record, partition_value: tpv, created_at: reference_time -  9.seconds),
        create(:bundle_record, partition_value: tpv, created_at: reference_time -  7.seconds), ## 6
        create(:bundle_record, partition_value: tpv, created_at: reference_time -  5.seconds),
        create(:bundle_record, partition_value: tpv, created_at: reference_time -  3.seconds), ## 8
        create(:bundle_record, partition_value: tpv, created_at: reference_time -  1.second ),
        create(:bundle_record, partition_value: npv, created_at: reference_time - 10.seconds), ]
    }

    let!(:bundle_record_bundles) {
      [ create(:bundle_record_bundle, partition_value: tpv, for_bundle_records: bundle_records.values_at(1,2), created_at: reference_time - 5.seconds),
        create(:bundle_record_bundle, partition_value: tpv, for_bundle_records: bundle_records.values_at(10),  created_at: reference_time - 4.seconds),
        create(:bundle_record_bundle, partition_value: tpv, for_bundle_records: bundle_records.values_at(4,5), created_at: reference_time - 3.seconds),
        create(:bundle_record_bundle, partition_value: tpv, for_bundle_records: bundle_records.values_at(9),   created_at: reference_time - 7.seconds), ]
    }

    let!(:bundle_record_confirmations) {
        [ create(:bundle_record_confirmation, for_bundle: bundle_record_bundles.fetch(1), receiver_uuid: target_receiver_uuid),
          create(:bundle_record_confirmation, for_bundle: bundle_record_bundles.fetch(0), receiver_uuid: nontarget_receiver_uuid), ]
    }

    let!(:split_time) { time = Time.now; sleep(0.001); time }

    context "when not all Bundle::RecordBundles are processed" do
      let(:given_max_bundles_to_process) { 2 }

      it "unconfirmed Bundle::RecordBundles are processed in creation order" do
        target_bundle_uuids = bundle_record_bundles.values_at(0,3).map(&:uuid)
        expect(action.fetch(:bundle_uuids)).to match_array(target_bundle_uuids)
      end

      it "the processed Bundle::RecordBundles' Model uuids are returned" do
        target_model_uuids = bundle_records.values_at(1,2,9).map(&:uuid)
        expect(action.fetch(:model_uuids)).to match_array(target_model_uuids)
      end
    end
    context "when all Bundle::RecordBundles are processed" do
      let(:given_max_bundles_to_process) { 4 }

      context "and the resulting Model uuid count meets/exceeds the goal" do
        let(:given_goal_records_to_return) { 3 }

        it "all unconfirmed Bundle::RecordBundles are processed" do
          target_bundle_uuids = bundle_record_bundles.values_at(0,2,3).map(&:uuid)
          expect(action.fetch(:bundle_uuids)).to match_array(target_bundle_uuids)
        end

        it "only the processed Bundle::RecordBundles' Model uuids are returned" do
          target_model_uuids = bundle_records.values_at(1,2,4,5,9).map(&:uuid)
          expect(action.fetch(:model_uuids)).to match_array(target_model_uuids)
        end
      end
      context "and the resulting Model uuid count does not meet the goal" do
        let(:given_goal_records_to_return) { 7 }

        it "all unconfirmed Bundle::RecordBundles are processed" do
          target_bundle_uuids = bundle_record_bundles.values_at(0,2,3).map(&:uuid)
          expect(action.fetch(:bundle_uuids)).to match_array(target_bundle_uuids)
        end

        it "the processed Bundle::RecordBundles' Model uuids are returned" do
          target_model_uuids = bundle_records.values_at(1,2,4,5,9).map(&:uuid)
          expect(action.fetch(:model_uuids)).to include(*target_model_uuids)
        end

        it "unbundled Bundle::Models are returned in creation order (up to the limit)" do
          target_model_uuids = bundle_records.values_at(6,3).map(&:uuid)
          expect(action.fetch(:model_uuids)).to include(*target_model_uuids)
        end
      end
    end
  end
end
