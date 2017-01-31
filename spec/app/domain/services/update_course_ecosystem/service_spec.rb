require 'rails_helper'

RSpec.describe Services::UpdateCourseEcosystem::Service, type: :service do
  let(:service)                { described_class.new }

  let(:given_request_uuid)     { SecureRandom.uuid }
  let(:given_preparation_uuid) { SecureRandom.uuid }

  let(:given_update_requests)  do
    [ { request_uuid: given_request_uuid, preparation_uuid: given_preparation_uuid } ]
  end

  let(:action)                 do
    service.process(update_requests: given_update_requests)
  end

  context "when a non-existing EcosystemPreparation uuid is given" do
    it "an EcosystemUpdate is NOT created" do
      expect{action}.not_to change{EcosystemUpdate.count}
    end

    it "the request_uuid is returned with update_status: 'preparation_unknown'" do
      update_response = action.fetch(:update_responses).first
      expect(update_response.fetch(:request_uuid)).to eq(given_request_uuid)
      expect(update_response.fetch(:update_status)).to eq('preparation_unknown')
    end
  end

  context "when an existing EcosystemPreparation uuid is given" do
    let!(:preparation) { FactoryGirl.create :ecosystem_preparation, uuid: given_preparation_uuid }

    context "and the preparation is obsolete" do
      before { FactoryGirl.create(:ecosystem_preparation, course: preparation.course) }

      it "an EcosystemUpdate is NOT created" do
        expect{action}.not_to change{EcosystemUpdate.count}
      end

      it "the request_uuid is returned with update_status: 'preparation_obsolete'" do
        update_response = action.fetch(:update_responses).first
        expect(update_response.fetch(:request_uuid)).to eq(given_request_uuid)
        expect(update_response.fetch(:update_status)).to eq('preparation_obsolete')
      end
    end

    context "and the preparation is not obsolete" do
      context "and the update already exists" do
        before { FactoryGirl.create :ecosystem_update, ecosystem_preparation: preparation }

        it "an EcosystemUpdate is NOT created" do
          expect{action}.not_to change{EcosystemUpdate.count}
        end

        it "the request_uuid is returned with update_status: 'updated_and_ready'" do
          update_response = action.fetch(:update_responses).first
          expect(update_response.fetch(:request_uuid)).to eq(given_request_uuid)
          expect(update_response.fetch(:update_status)).to eq('updated_and_ready')
        end
      end

      context "and the update does not yet exist" do
        it "an EcosystemUpdate is created with the correct attributes" do
          expect{action}.to change{EcosystemUpdate.count}.by(1)
          ecosystem_update = EcosystemUpdate.find_by(uuid: given_request_uuid)
          expect(ecosystem_update.preparation_uuid).to eq given_preparation_uuid
        end

        it "the request_uuid is returned with update_status: 'updated_but_unready'" do
          update_response = action.fetch(:update_responses).first
          expect(update_response.fetch(:request_uuid)).to eq(given_request_uuid)
          expect(update_response.fetch(:update_status)).to eq('updated_but_unready')
        end
      end
    end
  end
end
