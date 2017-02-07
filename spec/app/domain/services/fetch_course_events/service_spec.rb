require 'rails_helper'

RSpec.describe Services::FetchCourseEvents::Service, type: :service do
  let(:service)                        { described_class.new }

  let(:given_request_1_uuid)           { SecureRandom.uuid }
  let(:given_event_types_1)            do
    CourseEvent.types.keys.sample(rand(CourseEvent.types.size - 1) + 1)
  end
  let(:given_course_1_uuid)            { SecureRandom.uuid }
  let(:given_sequence_number_offset_1) { rand(1000000) }
  let(:given_event_limit_1)            { rand(1000) + 1 }
  let(:given_event_request_1)          do
    {
      request_uuid: given_request_1_uuid,
      event_types: given_event_types_1,
      course_uuid: given_course_1_uuid,
      sequence_number_offset: given_sequence_number_offset_1,
      event_limit: given_event_limit_1
    }
  end

  let(:given_request_2_uuid)           { SecureRandom.uuid }
  let(:given_event_types_2)            do
    CourseEvent.types.keys.sample(rand(CourseEvent.types.size - 1) + 1)
  end
  let(:given_course_2_uuid)            { SecureRandom.uuid }
  let(:given_sequence_number_offset_2) { rand(1000000) }
  let(:given_event_limit_2)            { rand(1000) + 1 }
  let(:given_event_request_2)          do
    {
      request_uuid: given_request_2_uuid,
      event_types: given_event_types_2,
      course_uuid: given_course_2_uuid,
      sequence_number_offset: given_sequence_number_offset_2,
      event_limit: given_event_limit_2
    }
  end

  let(:given_course_event_requests)    { [ given_event_request_1, given_event_request_2 ] }

  let(:requests_by_request_uuid)       do
    given_course_event_requests.index_by{ |request| request.fetch(:request_uuid) }
  end

  let(:action)                         do
    service.process(course_event_requests: given_course_event_requests)
  end

  let!(:target_event_1)                do
    FactoryGirl.create :course_event, course_uuid: given_course_1_uuid,
                                      sequence_number: given_sequence_number_offset_1,
                                      type: given_event_types_1.sample
  end
  let!(:target_event_2)                do
    FactoryGirl.create :course_event, course_uuid: given_course_2_uuid,
                                      sequence_number: given_sequence_number_offset_2,
                                      type: given_event_types_2.sample
  end

  let(:unhandled_event_types_1)        { CourseEvent.types.keys - given_event_types_1 }
  let!(:unhandled_event_1)             do
    FactoryGirl.create :course_event, course_uuid: given_course_1_uuid,
                                      sequence_number: given_sequence_number_offset_1 + 1,
                                      type: unhandled_event_types_1.sample
  end
  let(:unhandled_event_types_2)        { CourseEvent.types.keys - given_event_types_2 }
  let!(:unhandled_event_2)             do
    FactoryGirl.create :course_event, course_uuid: given_course_2_uuid,
                                      sequence_number: given_sequence_number_offset_2 + 1,
                                      type: unhandled_event_types_2.sample
  end

  let(:event_models_by_uuid)           { CourseEvent.all.index_by(&:uuid) }

  context "when there are no gaps in the CourseEvent sequence_numbers" do
    let!(:target_event_3)              do
      FactoryGirl.create :course_event, course_uuid: given_course_1_uuid,
                                        sequence_number: given_sequence_number_offset_1 + 2,
                                        type: given_event_types_1.sample
    end
    let!(:target_event_4)              do
      FactoryGirl.create :course_event, course_uuid: given_course_2_uuid,
                                        sequence_number: given_sequence_number_offset_2 + 2,
                                        type: given_event_types_2.sample
    end

    it "returns all events with is_stopped_at_gap: false" do
      action.fetch(:course_event_responses).each do |response|
        expect(requests_by_request_uuid.keys).to include response.fetch(:request_uuid)
        request = requests_by_request_uuid[response.fetch(:request_uuid)]
        expect(response.fetch(:course_uuid)).to eq request.fetch(:course_uuid)

        expect(response.fetch(:events).size).to eq 2
        response.fetch(:events).each do |event|
          event_model = event_models_by_uuid[event.fetch(:event_uuid)]
          expect(event_model.course_uuid).to eq response.fetch(:course_uuid)

          expect(event.fetch(:sequence_number)).to eq event_model.sequence_number
          expect(event.fetch(:event_type)).to eq event_model.type
          expect(event.fetch(:event_data)).to eq event_model.data
        end
        expect(response.fetch(:is_stopped_at_gap)).to eq false
      end
    end
  end

  context "when there are gaps in the CourseEvent sequence_numbers" do
    let!(:gap_event_1)                 do
      FactoryGirl.create :course_event, course_uuid: given_course_1_uuid,
                                        sequence_number: given_sequence_number_offset_1 + 3,
                                        type: given_event_types_1.sample
    end
    let!(:gap_event_2)                 do
      FactoryGirl.create :course_event, course_uuid: given_course_2_uuid,
                                        sequence_number: given_sequence_number_offset_2 + 3,
                                        type: given_event_types_2.sample
    end

    let(:gap_events)                   { [ gap_event_1, gap_event_2 ] }

    it "returns only events before the gap with is_stopped_at_gap: true" do
      action.fetch(:course_event_responses).each do |response|
        expect(requests_by_request_uuid.keys).to include response.fetch(:request_uuid)
        request = requests_by_request_uuid[response.fetch(:request_uuid)]
        expect(response.fetch(:course_uuid)).to eq request.fetch(:course_uuid)

        expect(response.fetch(:events).size).to eq 1
        response.fetch(:events).each do |event|
          event_model = event_models_by_uuid[event.fetch(:event_uuid)]
          expect(gap_events).not_to include(event_model)
          expect(event_model.course_uuid).to eq response.fetch(:course_uuid)

          expect(event.fetch(:sequence_number)).to eq event_model.sequence_number
          expect(event.fetch(:event_type)).to eq event_model.type
          expect(event.fetch(:event_data)).to eq event_model.data
        end
        expect(response.fetch(:is_stopped_at_gap)).to eq true
      end
    end
  end
end
