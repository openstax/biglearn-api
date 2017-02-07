require 'rails_helper'

RSpec.describe Services::UpdateCourseEcosystem::Service, type: :service do
  let(:service)                { described_class.new }

  let(:given_request_uuid)     { SecureRandom.uuid }
  let(:given_course_uuid)      { SecureRandom.uuid }
  let(:given_sequence_number)  { rand(1000) }
  let(:given_preparation_uuid) { SecureRandom.uuid }

  let(:given_update_requests)  do
    [
      {
        request_uuid: given_request_uuid,
        course_uuid: given_course_uuid,
        sequence_number: given_sequence_number,
        preparation_uuid: given_preparation_uuid
      }
    ]
  end

  let(:action)                 do
    service.process(update_requests: given_update_requests)
  end

  context "when a non-existing EcosystemPreparation uuid is given" do
    it "a CourseEvent is NOT created" do
      expect{action}.not_to change{CourseEvent.count}
    end

    it "the request_uuid is returned with update_status: 'preparation_unknown'" do
      update_response = action.fetch(:update_responses).first
      expect(update_response.fetch(:request_uuid)).to eq(given_request_uuid)
      expect(update_response.fetch(:update_status)).to eq('preparation_unknown')
    end
  end

  context "when an existing EcosystemPreparation uuid is given" do
    let!(:preparation) do
      FactoryGirl.create :course_event, uuid: given_preparation_uuid,
                                        type: :prepare_course_ecosystem,
                                        course_uuid: given_course_uuid
    end

    xcontext "and the preparation is obsolete" do
      # TODO: Figure out when this happens

      it "an EcosystemUpdate is NOT created" do
        expect{action}.not_to change{CourseEvent.count}
      end

      it "the request_uuid is returned with update_status: 'preparation_obsolete'" do
        update_response = action.fetch(:update_responses).first
        expect(update_response.fetch(:request_uuid)).to eq(given_request_uuid)
        expect(update_response.fetch(:update_status)).to eq('preparation_obsolete')
      end
    end

    context "and the preparation is not obsolete" do
      context "and the update is ready" do
        before { FactoryGirl.create :ecosystem_preparation_ready, uuid: given_preparation_uuid }

        it "a CourseEvent is created with the correct attributes" do
          expect{action}.to change{CourseEvent.count}.by(1)
          ecosystem_update = CourseEvent.find_by(uuid: given_request_uuid)
          data = ecosystem_update.data.deep_symbolize_keys
          expect(data.fetch(:preparation_uuid)).to eq given_preparation_uuid
        end

        it "the request_uuid is returned with update_status: 'updated_and_ready'" do
          update_response = action.fetch(:update_responses).first
          expect(update_response.fetch(:request_uuid)).to eq(given_request_uuid)
          expect(update_response.fetch(:update_status)).to eq('updated_and_ready')
        end
      end

      context "and the update is not ready" do
        it "a CourseEvent is created with the correct attributes" do
          expect{action}.to change{CourseEvent.count}.by(1)
          ecosystem_update = CourseEvent.find_by(uuid: given_request_uuid)
          expect(ecosystem_update.course_uuid).to eq(given_course_uuid)
          expect(ecosystem_update.sequence_number).to eq(given_sequence_number)
          data = ecosystem_update.data.deep_symbolize_keys
          expect(data.fetch(:preparation_uuid)).to eq given_preparation_uuid
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
