require 'rails_helper'

RSpec.describe CourseEventsController, type: :request do
  context '#fetch' do
    let(:given_request_1_uuid)           { SecureRandom.uuid }
    let(:given_event_types_1)            do
      CourseEvent.event_types.keys.sample(rand(CourseEvent.event_types.size) + 1)
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
      CourseEvent.event_types.keys.sample(rand(CourseEvent.event_types.size) + 1)
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

    let(:given_event_requests)          { [ given_event_request_1, given_event_request_2 ] }

    let(:request_payload)               { { course_event_requests: given_event_requests } }

    let(:target_event_uuid_1)           { SecureRandom.uuid }
    let(:target_event_type_1)           { CourseEvent.event_types.keys.sample }
    let(:target_event_data_1)           { {} }
    let(:target_event_1)                do
      [
        {
          sequence_number: given_sequence_number_offset_1,
          event_uuid: target_event_uuid_1,
          event_type: target_event_type_1,
          event_data: target_event_data_1
        }
      ]
    end
    let(:target_is_stopped_at_gap_1)    { [true, false].sample }
    let(:target_event_response_1)       do
      {
        request_uuid: given_request_1_uuid,
        course_uuid: given_course_1_uuid,
        events: target_event_1,
        is_stopped_at_gap: target_is_stopped_at_gap_1
      }
    end

    let(:target_event_uuid_2)           { SecureRandom.uuid }
    let(:target_event_type_2)           { CourseEvent.event_types.keys.sample }
    let(:target_event_data_2)           { {} }
    let(:target_event_2)                do
      [
        {
          sequence_number: given_sequence_number_offset_2,
          event_uuid: target_event_uuid_2,
          event_type: target_event_type_2,
          event_data: target_event_data_2
        }
      ]
    end
    let(:target_is_stopped_at_gap_2)    { [true, false].sample }
    let(:target_event_response_2)       do
      {
        request_uuid: given_request_2_uuid,
        course_uuid: given_course_2_uuid,
        events: target_event_2,
        is_stopped_at_gap: target_is_stopped_at_gap_2
      }
    end

    let(:target_event_responses)        { [ target_event_response_1, target_event_response_2 ] }

    let(:target_result)                 { { course_event_responses: target_event_responses } }
    let(:target_response)               { target_result }

    let(:service_double)                do
      object_double(Services::FetchCourseEvents::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each)                       do
      allow(Services::FetchCourseEvents::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = fetch_course_events(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = fetch_course_events(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the PrepareCourseEcosystem service is called with the correct course data" do
        response_status, response_body = fetch_course_events(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = fetch_course_events(request_payload: request_payload)
        expect(response_body).to eq(target_response.deep_stringify_keys)
      end
    end
  end

  protected

  def fetch_course_events(request_payload:)
    make_post_request(
      route: '/fetch_course_events',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end
end
