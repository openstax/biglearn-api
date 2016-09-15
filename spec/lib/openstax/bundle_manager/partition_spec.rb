require 'rails_helper'

RSpec.describe "Openstax::BundleManager::Manager: partitioning" do
  let(:manager) { Openstax::BundleManager::Manager.new(model: XTest1) }

  let(:action) { manager.partition(max_records_to_process: given_max_records_to_process) }

  let(:given_max_records_to_process) { 3 }

  context "when there are no Records" do
    it "no Bundle::Records are created" do
      expect{action}.to_not change{Bundle::XTest1.count}
    end
  end

  context "when there are Records" do
    let!(:partitioned_records) {
      [ create(:x_test1), create(:x_test1), create(:x_test1) ]
    }

    let!(:bundle_records) {
      partitioned_records.map do |record|
        create(:bundle_record, for_record: record)
      end
    }

    let(:reference_time) { Time.now }

    let!(:unpartitioned_records) {
      [ create(:x_test1, created_at: reference_time - 1.second ),
        create(:x_test1, created_at: reference_time - 3.seconds),
        create(:x_test1, created_at: reference_time - 5.seconds),
        create(:x_test1, created_at: reference_time - 4.seconds),
        create(:x_test1, created_at: reference_time - 2.seconds), ]
    }

    it "previously-partitioned Records are ignored" do
      expect{action}.to change{Bundle::XTest1.count}.by(given_max_records_to_process)
    end

    it "unpartitioned Records are processed in creation order" do
      action

      target_records = unpartitioned_records.values_at(2,3,1)
      bundle_records = Bundle::XTest1.where{uuid.in target_records.map(&:uuid)}

      expect(bundle_records.map(&:uuid)).to match_array(target_records.map(&:uuid))
    end

    context "maximum processing limits are honored:" do
      context "less than the number of unpartitioned Records" do
        let(:given_max_records_to_process) { 4 }

        it "works" do
          expect{action}.to change{Bundle::XTest1.count}.by(given_max_records_to_process)
        end
      end
      context "equal to the number of unpartitioned Records" do
        let(:given_max_records_to_process) { 5 }

        it "works" do
          expect{action}.to change{Bundle::XTest1.count}.by(given_max_records_to_process)
        end
      end
      context "more than the number of unpartitioned Records" do
        let(:given_max_records_to_process) { 6 }

        it "works" do
          expect{action}.to change{Bundle::XTest1.count}.by(unpartitioned_records.count)
        end
      end
    end
  end
end
