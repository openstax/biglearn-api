require 'rails_helper'

RSpec.describe "Openstax::BundleManager::Manager: bundling" do
  let(:manager) { Openstax::BundleManager::Manager.new(model: XTest1) }

  let(:action) {
    manager.bundle(
      max_records_to_process: given_max_records_to_process,
      max_records_per_bundle: given_max_records_per_bundle,
      max_age_per_bundle:     given_max_age_per_bundle,
      partition_count:        given_partition_count,
      partition_modulo:       given_partition_modulo,
    )
  }

  let(:given_max_records_to_process) { 5 }
  let(:given_max_records_per_bundle) { 2 }
  let(:given_max_age_per_bundle)     { 3.seconds }
  let(:given_partition_count)        { 5 }
  let(:given_partition_modulo)       { target_partition_modulo }

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

  context "when there are no Bundle::Records" do
    it "no Bundle::RecordBundles are created" do
      expect{action}.to_not change{Bundle::XTest1.count}
    end
    it "no Bundle::RecordEntries are created" do
      expect{action}.to_not change{Bundle::XTest1Entry.count}
    end
  end

  context "when there are Bundle::Records" do
    let!(:reference_time) { Time.now }

    let!(:bundle_records) {
      [ create(:bundle_record, partition_value: npv, created_at: reference_time - 11.seconds), ## 0
        create(:bundle_record, partition_value: tpv, created_at: reference_time -  2.seconds),
        create(:bundle_record, partition_value: tpv, created_at: reference_time -  4.seconds), ## 2
        create(:bundle_record, partition_value: tpv, created_at: reference_time -  6.seconds),
        create(:bundle_record, partition_value: tpv, created_at: reference_time -  8.seconds), ## 4
        create(:bundle_record, partition_value: npv, created_at: reference_time - 10.seconds),
        create(:bundle_record, partition_value: tpv, created_at: reference_time -  9.seconds), ## 6
        create(:bundle_record, partition_value: tpv, created_at: reference_time -  7.seconds),
        create(:bundle_record, partition_value: tpv, created_at: reference_time -  5.seconds), ## 8
        create(:bundle_record, partition_value: tpv, created_at: reference_time -  3.seconds),
        create(:bundle_record, partition_value: npv, created_at: reference_time -  1.second ),  ]
    }

    let!(:bundle_record_bundles) {
      [ create(:bundle_record_bundle, for_bundle_records: bundle_records.values_at(4,5)) ]
    }

    let(:target_unbundled_records) { bundle_records.values_at(6,7,3,8,2,9,1) }

    context "maximum processing limits are honored:" do
      context "less than the number of unbundled Bundle:Records" do
        let(:given_max_records_to_process) { 6 }

        let!(:split_time) { time = Time.now; sleep(0.001); time }

        it "previously-bundled Bundle::Records are ignored" do
          expect{action}.to change{Bundle::XTest1Entry.count}.by(6)
        end
        it "Bundle::Records are processed in creation order" do
          action

          target_records = target_unbundled_records.take(6)
          created_bundle_entries = Bundle::XTest1Entry.where{created_at > my{split_time}}
          expect(created_bundle_entries.map(&:uuid)).to match_array(target_records.map(&:uuid))
        end
        it "Bundle::RecordBundles are created" do
          expect{action}.to change{Bundle::XTest1Bundle.count}.by(3)
        end
      end
      context "equal to the number of unbundled Bundle:Records" do
        ##
        ## NOTE: The most recent target bundle is not old enough
        ##       to cause a Bundle to be formed.
        ##

        let(:given_max_records_to_process) { 7 }

        let!(:split_time) { time = Time.now; sleep(0.001); time }

        it "previously-bundled Bundle::Records are ignored" do
          expect{action}.to change{Bundle::XTest1Entry.count}.by(6)
        end
        it "Bundle::RecordBundles are created" do
          expect{action}.to change{Bundle::XTest1Bundle.count}.by(3)
        end
        it "Bundle::RecordEntries are created for unbundled Bundle::Records" do
          action

          target_records = target_unbundled_records.take(6)
          created_bundle_entries = Bundle::XTest1Entry.where{created_at > my{split_time}}
          expect(created_bundle_entries.map(&:uuid)).to match_array(target_records.map(&:uuid))
        end
      end
      context "more than the number of unbundled Bundle:Records" do
        let(:given_max_records_to_process) { 8 }
        let(:given_max_age_per_bundle)     { 0.seconds }

        let!(:split_time) { time = Time.now; sleep(0.001); time }

        it "previously-bundled Bundle::Records are ignored" do
          expect{action}.to change{Bundle::XTest1Entry.count}.by(7)
        end
        it "Bundle::RecordBundles are created" do
          expect{action}.to change{Bundle::XTest1Bundle.count}.by(4)
        end
        it "Bundle::RecordEntries are created for unbundled Bundle::Records" do
          action

          created_bundle_entries = Bundle::XTest1Entry.where{created_at > my{split_time}}
          expect(created_bundle_entries.map(&:uuid)).to match_array(target_unbundled_records.map(&:uuid))
        end
      end
    end
  end
end
