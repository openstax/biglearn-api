require 'rails_helper'

RSpec.describe "Openstax::BundleManager::Manager: confirmation" do
  let(:manager) { Openstax::BundleManager::Manager.new(model: XTest1) }

  let(:action) {
    manager.confirm(
      receiver_uuid:           given_receiver_uuid,
      bundle_uuids_to_confirm: given_bundle_uuids_to_confirm,
    )
  }

  let(:given_receiver_uuid)           { SecureRandom.uuid.to_s }
  let(:given_bundle_uuids_to_confirm) { [] }

  context "when there are no Bundle::RecordBundles" do
    context "and no Bundle::RecordBundle uuids are confirmed" do
      let(:given_bundle_uuids_to_confirm) { [] }

      it "no Bundle::RecordConfirmations are created" do
        expect{action}.to_not change{Bundle::XTest1Confirmation.count}
      end

      it "no confirmed Bundle::RecordBundle uuids are returned" do
        expect(action).to be_empty
      end
    end
    context "and [invalid] Bundles::RecordBundle uuids are confirmed" do
      let(:given_bundle_uuids_to_confirm) { [ SecureRandom.uuid.to_s, SecureRandom.uuid.to_s ] }

      it "no Bundle::RecordConfirmations are created" do
        expect{action}.to_not change{Bundle::XTest1Confirmation.count}
      end

      it "no confirmed Bundle::RecordBundle uuids are returned" do
        expect(action).to be_empty
      end
    end
  end

  context "when there are Bundle::RecordBundles" do
    let!(:bundles) {
      [ create(:bundle_record_bundle, confirmed_by: [SecureRandom.uuid.to_s, given_receiver_uuid]),
        create(:bundle_record_bundle, confirmed_by: [SecureRandom.uuid.to_s]),
        create(:bundle_record_bundle, confirmed_by: [given_receiver_uuid, SecureRandom.uuid.to_s]),
        create(:bundle_record_bundle, confirmed_by: []),
        create(:bundle_record_bundle, confirmed_by: [SecureRandom.uuid.to_s]), ]
    }

    let(:confirmed_bundles)   { bundles.values_at(0,2) }
    let(:unconfirmed_bundles) { bundles.values_at(1,3,4) }

    context "and no Bundle::RecordBundle uuids are confirmed" do
      let(:given_bundle_uuids_to_confirm) { [] }

      it "no Bundle::RecordConfirmations are created" do
        expect{action}.to_not change{Bundle::XTest1Confirmation.count}
      end

      it "no confirmed Bundle::RecordBundle uuids are returned" do
        expect(action).to be_empty
      end
    end
    context "and Bundle::RecordBundle uuids are confirmed" do
      let(:previously_confirmed_bundle_uuids) { bundles.values_at(2).map(&:uuid) }
      let(:newly_confirmed_bundle_uuids)      { bundles.values_at(1,3).map(&:uuid) }
      let(:invalid_bundle_uuids)              { [SecureRandom.uuid.to_s] }

      let(:given_bundle_uuids_to_confirm) {
        (previously_confirmed_bundle_uuids + newly_confirmed_bundle_uuids + invalid_bundle_uuids).shuffle
      }

      let!(:split_time) { time = Time.now; sleep(0.001); time }

      it "no Bundle::RecordConfirmations are created for invalid Bundle::RecordBundle uuids" do
        expect{action}.to change{Bundle::XTest1Confirmation.count}.by(2)
      end
      it "no Bundle::RecordConfirmations are created for previously-confirmed Bundle::RecordBundle uuids" do
        expect{action}.to change{Bundle::XTest1Confirmation.count}.by(2)
      end
      it "Bundle::RecordConfirmations are created for newly-confirmed Bundle::RecordBundle uuids" do
        action
        created_confirmations = Bundle::XTest1Confirmation.where{created_at > my{split_time}}.to_a
        expect(created_confirmations.map(&:bundle_uuid)).to match_array(newly_confirmed_bundle_uuids)
      end
      it "Bundle::RecordBundle uuids are returned for all given valid, confirmed Bundle::RecordBundle uuids (idempotence)" do
        expect(action).to match_array(previously_confirmed_bundle_uuids + newly_confirmed_bundle_uuids)
      end
    end
  end
end
