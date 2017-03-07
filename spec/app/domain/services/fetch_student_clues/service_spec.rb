require 'rails_helper'

RSpec.describe Services::FetchStudentClues::Service, type: :service do
  let(:service)                              { described_class.new }

  let(:given_algorithm_name)                 { 'SPARFA' }

  let(:given_request_1_uuid)                 { SecureRandom.uuid }
  let(:given_student_1_uuid)                 { SecureRandom.uuid }
  let(:given_book_container_1_uuid)          { SecureRandom.uuid }
  let(:given_request_2_uuid)                 { SecureRandom.uuid }
  let(:given_student_2_uuid)                 { SecureRandom.uuid }
  let(:given_book_container_2_uuid)          { SecureRandom.uuid }

  let(:given_clue_requests)                  do
    [
      {
        request_uuid: given_request_1_uuid,
        student_uuid: given_student_1_uuid,
        book_container_uuid: given_book_container_1_uuid,
        algorithm_name: given_algorithm_name
      },
      {
        request_uuid: given_request_2_uuid,
        student_uuid: given_student_2_uuid,
        book_container_uuid: given_book_container_2_uuid,
        algorithm_name: given_algorithm_name
      }
    ]
  end

  let(:action)                               do
    service.process(student_clue_requests: given_clue_requests)
  end

  let(:book_container_uuids_by_request_uuid) do
    {
      given_request_1_uuid => given_book_container_1_uuid,
      given_request_2_uuid => given_book_container_2_uuid
    }
  end

  let(:default_clue_data)                    do
    {
      minimum: 0,
      most_likely: 0.5,
      maximum: 1,
      is_real: false
    }
  end

  context "when non-existing book_container uuids are given" do
    it "the request_uuid is returned with clue_status: 'book_container_unknown'" do
      action.fetch(:student_clue_responses).each do |response|
        request_uuid = response.fetch(:request_uuid)
        book_container_uuid = book_container_uuids_by_request_uuid.fetch request_uuid
        expect(response.fetch(:clue_data)).to eq default_clue_data
        expect(response.fetch(:clue_status)).to eq 'book_container_unknown'
      end
    end
  end

  context "when existing book_container uuids are given" do
      let!(:book_container_1) do
        FactoryGirl.create :book_container, uuid: given_book_container_1_uuid
      end
      let!(:book_container_2) do
        FactoryGirl.create :book_container, uuid: given_book_container_2_uuid
      end

    context "when non-existing student uuids are given" do
      it "the request_uuid is returned with clue_status: 'student_unknown'" do
        action.fetch(:student_clue_responses).each do |response|
          request_uuid = response.fetch(:request_uuid)
          book_container_uuid = book_container_uuids_by_request_uuid.fetch request_uuid
          book_container = BookContainer.find_by uuid: book_container_uuid
          expect(response.fetch(:clue_data)).to eq(
            default_clue_data.merge(ecosystem_uuid: book_container.ecosystem_uuid)
          )
          expect(response.fetch(:clue_status)).to eq 'student_unknown'
        end
      end
    end

    context "when existing student uuids are given" do
      let!(:student_1) do
        FactoryGirl.create :student, uuid: given_student_1_uuid
      end
      let!(:student_2) do
        FactoryGirl.create :student, uuid: given_student_2_uuid
      end

      context "when the CLUe is not yet ready" do
        it "the request_uuid is returned with clue_status: 'clue_unready'" do
          action.fetch(:student_clue_responses).each do |response|
            request_uuid = response.fetch(:request_uuid)
            book_container_uuid = book_container_uuids_by_request_uuid.fetch request_uuid
            book_container = BookContainer.find_by uuid: book_container_uuid
            expect(response.fetch(:clue_data)).to eq(
              default_clue_data.merge(ecosystem_uuid: book_container.ecosystem_uuid)
            )
            expect(response.fetch(:clue_status)).to eq 'clue_unready'
          end
        end
      end

      context "when the CLUe is ready" do
        let!(:clue_1) do
          FactoryGirl.create :student_clue, student_uuid: given_student_1_uuid,
                                            book_container_uuid: given_book_container_1_uuid,
                                            algorithm_name: given_algorithm_name
        end
        let!(:clue_2) do
          FactoryGirl.create :student_clue, student_uuid: given_student_2_uuid,
                                            book_container_uuid: given_book_container_2_uuid,
                                            algorithm_name: given_algorithm_name
        end

        it "the request_uuid is returned with clue_status: 'clue_ready'" do
          clues = [ clue_1, clue_2 ]

          action.fetch(:student_clue_responses).each_with_index do |response, index|
            clue = clues[index]
            expect(response.fetch(:clue_data)).to eq clue.data
            expect(response.fetch(:clue_status)).to eq 'clue_ready'
          end
        end
      end
    end
  end
end
