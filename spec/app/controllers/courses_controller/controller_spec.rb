require 'rails_helper'

RSpec.describe CoursesController, type: :request do
  context '#create_course' do
    let(:request_payload) {
      {
        course_uuid:    given_course_uuid,
        ecosystem_uuid: given_ecosystem_uuid
      }
    }

    let(:given_course_uuid)     { SecureRandom.uuid }
    let(:given_ecosystem_uuid)  { SecureRandom.uuid }

    let(:target_result)         {
      { created_course_uuid: given_course_uuid }
    }

    let(:service_double) {
      dbl = object_double(Services::CreateCourse::Service.new)
      allow(dbl).to receive(:process)
                .with(
                  course_uuid:    given_course_uuid,
                  ecosystem_uuid: given_ecosystem_uuid
                )
                .and_return(target_result)
      dbl
    }

    before(:each) do
      allow(Services::CreateCourse::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(CoursesController).to receive(:with_json_apis).and_call_original
        response_status, response_body = create_course(request_payload: request_payload)
      end
      it "the response has status 200 (success)" do
        response_status, response_body = create_course(request_payload: request_payload)
        expect(response_status).to eq(200)
      end
      it "the CreateCourse service is called with the correct course data" do
        response_status, response_body = create_course(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end
      it "the response contains the course uuid returned by the CreateCourse service" do
        response_status, response_body = create_course(request_payload: request_payload)
        expect(response_body.fetch('created_course_uuid')).to eq(given_course_uuid)
      end
    end
  end

  context '#fetch_course_metadatas' do
    let(:courses_count)           { rand(10) + 1 }

    let(:target_result)           do
      {
        course_responses: courses_count.times.map do
          {
            uuid: SecureRandom.uuid,
            initial_ecosystem_uuid: SecureRandom.uuid
          }
        end
      }
    end

    let(:service_double)          do
      object_double(Services::FetchCourseMetadatas::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).and_return(target_result)
      end
    end

    before(:each) do
      allow(Services::FetchCourseMetadatas::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = fetch_course_metadatas
      end

      it "the response has status 200 (success)" do
        response_status, response_body = fetch_course_metadatas
        expect(response_status).to eq(200)
      end

      it "the FetchCourseMetadatas service is called with the correct course data" do
        response_status, response_body = fetch_course_metadatas
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_result" do
        response_status, response_body = fetch_course_metadatas
        expect(response_body).to eq(target_result.deep_stringify_keys)
      end
    end
  end

  context '#fetch_events' do
    let(:given_request_1_uuid)           { SecureRandom.uuid }
    let(:given_event_types_1)            do
      CourseEvent.types.keys.sample(rand(CourseEvent.types.size) + 1)
    end
    let(:given_course_1_uuid)            { SecureRandom.uuid }
    let(:given_sequence_number_offset_1) { rand(1000000) }
    let(:given_max_num_events_1)            { rand(100) + 1 }
    let(:given_event_request_1)          do
      {
        request_uuid: given_request_1_uuid,
        event_types: given_event_types_1,
        course_uuid: given_course_1_uuid,
        sequence_number_offset: given_sequence_number_offset_1,
        max_num_events: given_max_num_events_1
      }
    end

    let(:given_request_2_uuid)           { SecureRandom.uuid }
    let(:given_event_types_2)            do
      CourseEvent.types.keys.sample(rand(CourseEvent.types.size) + 1)
    end
    let(:given_course_2_uuid)            { SecureRandom.uuid }
    let(:given_sequence_number_offset_2) { rand(1000000) }
    let(:given_max_num_events_2)            { rand(100) + 1 }
    let(:given_event_request_2)          do
      {
        request_uuid: given_request_2_uuid,
        event_types: given_event_types_2,
        course_uuid: given_course_2_uuid,
        sequence_number_offset: given_sequence_number_offset_2,
        max_num_events: given_max_num_events_2
      }
    end

    let(:given_event_requests)          { [ given_event_request_1, given_event_request_2 ] }

    let(:request_payload)               { { course_event_requests: given_event_requests } }

    let(:target_event_uuid_1)           { SecureRandom.uuid }
    let(:target_event_type_1)           { CourseEvent.types.keys.sample }
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
    let(:target_is_gap_1)               { [true, false].sample }
    let(:target_is_end_1)               { [true, false].sample }
    let(:target_event_response_1)       do
      {
        request_uuid: given_request_1_uuid,
        course_uuid: given_course_1_uuid,
        events: target_event_1,
        is_gap: target_is_gap_1,
        is_end: target_is_end_1
      }
    end

    let(:target_event_uuid_2)           { SecureRandom.uuid }
    let(:target_event_type_2)           { CourseEvent.types.keys.sample }
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
    let(:target_is_gap_2)               { [true, false].sample }
    let(:target_is_end_2)               { [true, false].sample }
    let(:target_event_response_2)       do
      {
        request_uuid: given_request_2_uuid,
        course_uuid: given_course_2_uuid,
        events: target_event_2,
        is_gap: target_is_gap_2,
        is_end: target_is_end_2
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

      it "the FetchCourseEvents service is called with the correct course data" do
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

  def create_course(request_payload:)
    make_post_request(
      route: '/create_course',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

  def fetch_course_metadatas
    make_post_request(
      route: '/fetch_course_metadatas'
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

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
