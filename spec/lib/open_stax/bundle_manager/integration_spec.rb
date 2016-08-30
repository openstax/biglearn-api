require 'rails_helper'

RSpec.describe OpenStax::BundleManager::Manager do
  let(:manager) { OpenStax::BundleManager::Manager.new(model: XTest1) }

  context "elaborate scenario" do
    let!(:x_test1s) {
      100.times.map do
        create(:x_test1)
      end
    }

    let(:target_receiver_uuid) { SecureRandom.uuid.to_s }

    it "works" do
      ##
      ## partitioning creates Bundle::Model records
      ##

      expect{manager.partition(max_records_to_process: 50)}.to change{Bundle::XTest1.count}.by(50)
      expect{manager.partition(max_records_to_process: 10)}.to change{Bundle::XTest1.count}.by(10)

      ##
      ## confirming with invalid Bundle::ModelBundle uuids does nothing
      ##

      bundle_uuids = [ SecureRandom.uuid.to_s ]
      confirmed_bundle_uuids = nil
      expect{
        confirmed_bundle_uuids = manager.confirm(
          receiver_uuid:           target_receiver_uuid,
          bundle_uuids_to_confirm: bundle_uuids
        )
      }.to_not change{Bundle::XTest1Confirmation.count}
      expect(confirmed_bundle_uuids).to be_empty

      ##
      ## bundling creates Bundle::ModelBundle records
      ##

      manager.bundle(
        max_records_to_process: 25,
        max_records_per_bundle: 10,
        max_age_per_bundle:     0.seconds,
        partition_count:        1,
        partition_modulo:       0,
      )
      manager.bundle(
        max_records_to_process: 25,
        max_records_per_bundle: 10,
        max_age_per_bundle:     0.seconds,
        partition_count:        1,
        partition_modulo:       0,
      )
      expect(Bundle::XTest1Bundle.count).to eq(6)
      expect(Bundle::XTest1Entry.count).to eq(50)

      ##
      ## fetch returns Bundle::ModelBundle and Model uuids
      ##

      results1 = manager.fetch(
        max_bundles_to_return: 2,
        receiver_uuid:         target_receiver_uuid,
        partition_count:       1,
        partition_modulo:      0,
      )
      expect(results1.fetch(:bundle_uuids).count).to eq(2)
      expect(results1.fetch(:model_uuids)).to_not be_empty

      ##
      ## fetch returns the same results when nothing has been confirmed
      ##

      results2 = manager.fetch(
        max_bundles_to_return: 2,
        receiver_uuid:         target_receiver_uuid,
        partition_count:       1,
        partition_modulo:      0,
      )
      expect(results2).to eq(results1)

      ##
      ## confirming causes new results to be returned
      ##

      confirmed_bundle_uuids = manager.confirm(
        receiver_uuid:           target_receiver_uuid,
        bundle_uuids_to_confirm: results1.fetch(:bundle_uuids),
      )
      expect(confirmed_bundle_uuids).to match_array(results1.fetch(:bundle_uuids))
    end
  end
end
