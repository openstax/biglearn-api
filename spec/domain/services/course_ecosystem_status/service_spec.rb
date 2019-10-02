require 'rails_helper'

RSpec.describe Services::CourseEcosystemStatus::Service, type: :service do
  let(:service)            { described_class.new }

  let(:given_request_uuid) { SecureRandom.uuid }
  let(:given_course_uuid)  { SecureRandom.uuid }
  let(:given_course_uuids) { [ given_course_uuid ] }

  let(:action)             do
    service.process(request_uuid: given_request_uuid, course_uuids: given_course_uuids)
  end

  context "when a non-existing course_uuid is given" do
    it "the course_uuid is returned with course_is_known: false" do
      course_status = action.fetch(:course_statuses).first
      expect(course_status.fetch(:course_uuid)).to eq given_course_uuid
      expect(course_status.fetch(:course_is_known)).to eq false
      expect(course_status.fetch(:current_ecosystem_preparation_uuid)).to be_nil

      current_ecosystem_status = course_status.fetch(:current_ecosystem_status)
      expect(current_ecosystem_status.fetch(:ecosystem_uuid)).to be_nil
      expect(current_ecosystem_status.fetch(:ecosystem_is_known)).to eq false
      expect(current_ecosystem_status.fetch(:ecosystem_is_prepared)).to eq false
      expect(current_ecosystem_status.fetch(:precompute_is_complete)).to eq false

      next_ecosystem_status = course_status.fetch(:next_ecosystem_status)
      expect(next_ecosystem_status.fetch(:ecosystem_uuid)).to be_nil
      expect(next_ecosystem_status.fetch(:ecosystem_is_known)).to eq false
      expect(next_ecosystem_status.fetch(:ecosystem_is_prepared)).to eq false
      expect(next_ecosystem_status.fetch(:precompute_is_complete)).to eq false
    end
  end

  context "when an existing course_uuid is given" do
    let(:initial_ecosystem_uuid) { SecureRandom.uuid }
    let!(:create_ecosystem)      do
      FactoryBot.create :ecosystem_event, uuid: initial_ecosystem_uuid,
                                           ecosystem_uuid: initial_ecosystem_uuid,
                                           type: :create_ecosystem,
                                           data: { ecosystem_uuid: initial_ecosystem_uuid }
    end
    let!(:create_course)         do
      FactoryBot.create :course_event, uuid: given_course_uuid,
                                        course_uuid: given_course_uuid,
                                        type: :create_course,
                                        data: { ecosystem_uuid: initial_ecosystem_uuid }
    end

    context "and the next ecosystem is unknown" do
      it "the course_uuid is returned with the current ecosystem information" do
        course_status = action.fetch(:course_statuses).first
        expect(course_status.fetch(:course_uuid)).to eq given_course_uuid
        expect(course_status.fetch(:course_is_known)).to eq true
        expect(course_status.fetch(:current_ecosystem_preparation_uuid)).to be_nil

        current_ecosystem_status = course_status.fetch(:current_ecosystem_status)
        expect(current_ecosystem_status.fetch(:ecosystem_uuid)).to eq initial_ecosystem_uuid
        expect(current_ecosystem_status.fetch(:ecosystem_is_known)).to eq true
        expect(current_ecosystem_status.fetch(:ecosystem_is_prepared)).to eq false
        expect(current_ecosystem_status.fetch(:precompute_is_complete)).to eq false

        next_ecosystem_status = course_status.fetch(:next_ecosystem_status)
        expect(next_ecosystem_status.fetch(:ecosystem_uuid)).to be_nil
        expect(next_ecosystem_status.fetch(:ecosystem_is_known)).to eq false
        expect(next_ecosystem_status.fetch(:ecosystem_is_prepared)).to eq false
        expect(next_ecosystem_status.fetch(:precompute_is_complete)).to eq false
      end
    end

    context "and the next ecosystem is prepared" do
      let(:next_ecosystem_uuid) { SecureRandom.uuid }
      let!(:next_ecosystem)      do
        FactoryBot.create :ecosystem_event, uuid: next_ecosystem_uuid,
                                             ecosystem_uuid: next_ecosystem_uuid,
                                             type: :create_ecosystem
      end
      let!(:preparation) do
        FactoryBot.create :course_event, course_uuid: given_course_uuid,
                                          type: :prepare_course_ecosystem,
                                          data: {
                                            preparation_uuid: SecureRandom.uuid,
                                            next_ecosystem_uuid: next_ecosystem_uuid,
                                            ecosystem_map: {}
                                          }
      end

      context "but precompute is not complete" do
        it "the course_uuid is returned with the current and next ecosystem information" do
          course_status = action.fetch(:course_statuses).first
          expect(course_status.fetch(:course_uuid)).to eq given_course_uuid
          expect(course_status.fetch(:course_is_known)).to eq true
          expect(course_status.fetch(:current_ecosystem_preparation_uuid)).to eq preparation.uuid

          current_ecosystem_status = course_status.fetch(:current_ecosystem_status)
          expect(current_ecosystem_status.fetch(:ecosystem_uuid)).to eq initial_ecosystem_uuid
          expect(current_ecosystem_status.fetch(:ecosystem_is_known)).to eq true
          expect(current_ecosystem_status.fetch(:ecosystem_is_prepared)).to eq false
          expect(current_ecosystem_status.fetch(:precompute_is_complete)).to eq false

          next_ecosystem_status = course_status.fetch(:next_ecosystem_status)
          expect(next_ecosystem_status.fetch(:ecosystem_uuid)).to eq next_ecosystem_uuid
          expect(next_ecosystem_status.fetch(:ecosystem_is_known)).to eq true
          expect(next_ecosystem_status.fetch(:ecosystem_is_prepared)).to eq true
          expect(next_ecosystem_status.fetch(:precompute_is_complete)).to eq false
        end
      end

      context "and precompute is complete" do
        let!(:ready) do
          FactoryBot.create :ecosystem_preparation_ready, uuid: preparation.uuid
        end

        context "but the update has not yet been made" do
          it "the course_uuid is returned with the current and next ecosystem information" do
            course_status = action.fetch(:course_statuses).first
            expect(course_status.fetch(:course_uuid)).to eq given_course_uuid
            expect(course_status.fetch(:course_is_known)).to eq true
            expect(course_status.fetch(:current_ecosystem_preparation_uuid)).to eq preparation.uuid

            current_ecosystem_status = course_status.fetch(:current_ecosystem_status)
            expect(current_ecosystem_status.fetch(:ecosystem_uuid)).to eq initial_ecosystem_uuid
            expect(current_ecosystem_status.fetch(:ecosystem_is_known)).to eq true
            expect(current_ecosystem_status.fetch(:ecosystem_is_prepared)).to eq false
            expect(current_ecosystem_status.fetch(:precompute_is_complete)).to eq false

            next_ecosystem_status = course_status.fetch(:next_ecosystem_status)
            expect(next_ecosystem_status.fetch(:ecosystem_uuid)).to eq next_ecosystem_uuid
            expect(next_ecosystem_status.fetch(:ecosystem_is_known)).to eq true
            expect(next_ecosystem_status.fetch(:ecosystem_is_prepared)).to eq true
            expect(next_ecosystem_status.fetch(:precompute_is_complete)).to eq true
          end
        end

        context "and the update has already been made" do
          let!(:update) do
            FactoryBot.create :course_event, course_uuid: given_course_uuid,
                                              type: :update_course_ecosystem,
                                              data: { preparation_uuid: preparation.uuid }
          end

          it "the prepared ecosystem becomes current" do
            course_status = action.fetch(:course_statuses).first
            expect(course_status.fetch(:course_uuid)).to eq given_course_uuid
            expect(course_status.fetch(:course_is_known)).to eq true
            expect(course_status.fetch(:current_ecosystem_preparation_uuid)).to be_nil

            current_ecosystem_status = course_status.fetch(:current_ecosystem_status)
            expect(current_ecosystem_status.fetch(:ecosystem_uuid)).to eq next_ecosystem_uuid
            expect(current_ecosystem_status.fetch(:ecosystem_is_known)).to eq true
            expect(current_ecosystem_status.fetch(:ecosystem_is_prepared)).to eq true
            expect(current_ecosystem_status.fetch(:precompute_is_complete)).to eq true

            next_ecosystem_status = course_status.fetch(:next_ecosystem_status)
            expect(next_ecosystem_status.fetch(:ecosystem_uuid)).to be_nil
            expect(next_ecosystem_status.fetch(:ecosystem_is_known)).to eq false
            expect(next_ecosystem_status.fetch(:ecosystem_is_prepared)).to eq false
            expect(next_ecosystem_status.fetch(:precompute_is_complete)).to eq false
          end
        end
      end
    end
  end
end
