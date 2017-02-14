require 'rails_helper'

RSpec.describe Services::FetchTeacherClues::Service, type: :service do
  let(:service)                              { described_class.new }

  let(:given_request_1_uuid)                 { SecureRandom.uuid }
  let(:given_course_container_1_uuid)        { SecureRandom.uuid }
  let(:given_book_container_1_uuid)          { SecureRandom.uuid }
  let(:given_request_2_uuid)                 { SecureRandom.uuid }
  let(:given_course_container_2_uuid)        { SecureRandom.uuid }
  let(:given_book_container_2_uuid)          { SecureRandom.uuid }

  let(:given_clue_requests)                  do
    [
      {
        request_uuid: given_request_1_uuid,
        course_container_uuid: given_course_container_1_uuid,
        book_container_uuid: given_book_container_1_uuid
      },
      {
        request_uuid: given_request_2_uuid,
        course_container_uuid: given_course_container_2_uuid,
        book_container_uuid: given_book_container_2_uuid
      }
    ]
  end

  let(:action)                               do
    service.process(teacher_clue_requests: given_clue_requests)
  end

  let(:book_container_uuids_by_request_uuid) do
    {
      given_request_1_uuid => given_book_container_1_uuid,
      given_request_2_uuid => given_book_container_2_uuid
    }
  end

  let(:default_clue_data)                    do
    lambda do |pool_id|
      {
        aggregate: 0.5,
        confidence: {
          left: 0,
          right: 1,
          sample_size: 0,
          unique_learner_count: 0
        },
        interpretation: {
          confidence: 'bad',
          level: 'low',
          threshold: 'below'
        },
        pool_id: pool_id
      }
    end
  end

  context "when non-existing book_container uuids are given" do
    it "the request_uuid is returned with clue_status: 'book_container_unknown'" do
      action.fetch(:teacher_clue_responses).each do |response|
        expect(book_container_uuids_by_request_uuid.keys).to include(response.fetch(:request_uuid))
        book_container_uuid = book_container_uuids_by_request_uuid[response.fetch(:request_uuid)]
        expect(response.fetch(:clue_data)).to eq default_clue_data.call(book_container_uuid)
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

    context "when non-existing course_container uuids are given" do
      it "the request_uuid is returned with clue_status: 'course_container_unknown'" do
        action.fetch(:teacher_clue_responses).each do |response|
          expect(book_container_uuids_by_request_uuid.keys).to include(response.fetch(:request_uuid))
          book_container_uuid = book_container_uuids_by_request_uuid[response.fetch(:request_uuid)]
          expect(response.fetch(:clue_data)).to eq default_clue_data.call(book_container_uuid)
          expect(response.fetch(:clue_status)).to eq 'course_container_unknown'
        end
      end
    end

    context "when existing course_container uuids are given" do
      let!(:course_container_1) do
        FactoryGirl.create :course_container, uuid: given_course_container_1_uuid
      end
      let!(:course_container_2) do
        FactoryGirl.create :course_container, uuid: given_course_container_2_uuid
      end

      context "when the CLUe is not yet ready" do
        it "the request_uuid is returned with clue_status: 'clue_unready'" do
          action.fetch(:teacher_clue_responses).each do |response|
            expect(book_container_uuids_by_request_uuid.keys).to include(response.fetch(:request_uuid))
            book_container_uuid = book_container_uuids_by_request_uuid[response.fetch(:request_uuid)]
            expect(response.fetch(:clue_data)).to eq default_clue_data.call(book_container_uuid)
            expect(response.fetch(:clue_status)).to eq 'clue_unready'
          end
        end
      end

      context "when the CLUe is ready" do
        let!(:clue_1) do
          FactoryGirl.create :teacher_clue, course_container_uuid: given_course_container_1_uuid,
                                            book_container_uuid: given_book_container_1_uuid
        end
        let!(:clue_2) do
          FactoryGirl.create :teacher_clue, course_container_uuid: given_course_container_2_uuid,
                                            book_container_uuid: given_book_container_2_uuid
        end

        it "the request_uuid is returned with clue_status: 'clue_ready'" do
          clues = [ clue_1, clue_2 ]

          action.fetch(:teacher_clue_responses).each_with_index do |response, index|
            expect(book_container_uuids_by_request_uuid.keys).to include(response.fetch(:request_uuid))

            clue = clues[index]
            expect(response.fetch(:clue_data)).to eq( {
              aggregate: clue.aggregate,
              confidence: {
                left: clue.confidence_left,
                right: clue.confidence_right,
                sample_size: clue.sample_size,
                unique_learner_count: clue.unique_learner_count
              },
              interpretation: {
                confidence: clue.is_good_confidence ? 'good' : 'bad',
                level: clue.is_high_level ? 'high' : 'low',
                threshold: clue.is_above_threshold ? 'above' : 'below'
              },
              pool_id: clue.book_container_uuid
            } )

            expect(response.fetch(:clue_status)).to eq 'clue_ready'
          end
        end
      end
    end
  end
end
