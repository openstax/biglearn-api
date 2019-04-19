require 'rails_helper'

RSpec.describe CoursesController, type: :request do
  context '#create_course' do
    let(:given_course_uuid)    { SecureRandom.uuid                 }
    let(:given_ecosystem_uuid) { SecureRandom.uuid                 }
    let(:given_is_real_course) { [ true, false ].sample            }
    let(:given_starts_at)      { Time.current.iso8601(6)           }
    let(:given_ends_at)        { Time.current.tomorrow.iso8601(6)  }
    let(:given_created_at)     { Time.current.yesterday.iso8601(6) }

    let(:request_payload)      do
      {
        course_uuid: given_course_uuid,
        ecosystem_uuid: given_ecosystem_uuid,
        is_real_course: given_is_real_course,
        starts_at: given_starts_at,
        ends_at: given_ends_at,
        created_at: given_created_at
      }
    end

    let(:target_result)        { { created_course_uuid: given_course_uuid } }

    let(:service_double)       do
      object_double(Services::CreateCourse::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each)              do
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

  context '#update_course_active_dates' do
    let(:given_request_uuid)    { SecureRandom.uuid }
    let(:given_course_uuid)     { SecureRandom.uuid }
    let(:given_sequence_number) { rand(10) }
    let(:given_starts_at)       { Time.current.yesterday.iso8601(6) }
    let(:given_ends_at)         { Time.current.tomorrow.iso8601(6) }
    let(:given_updated_at)      { Time.current.iso8601(6) }

    let(:request_payload)       do
      {
        request_uuid: given_request_uuid,
        course_uuid: given_course_uuid,
        sequence_number: given_sequence_number,
        starts_at: given_starts_at,
        ends_at: given_ends_at,
        updated_at: given_updated_at
      }
    end

    let(:target_result)         { { updated_course_uuid: given_course_uuid } }
    let(:target_response)       { target_result }

    let(:service_double)        do
      object_double(Services::UpdateCourseActiveDates::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each)               do
      allow(Services::UpdateCourseActiveDates::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = update_course_active_dates(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = update_course_active_dates(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the CreateEcosystem service is called with the correct course data" do
        response_status, response_body = update_course_active_dates(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = update_course_active_dates(request_payload: request_payload)
        expect(response_body).to eq(target_response.deep_stringify_keys)
      end
    end
  end

  context '#fetch_course_metadatas' do
    let(:courses_count)                         { rand(10) + 1        }
    let(:given_metadata_sequence_number_offset) { rand(courses_count) }
    let(:given_max_num_metadatas)               { 1000 }

    let(:request_payload)                       do
      {
        metadata_sequence_number_offset: given_metadata_sequence_number_offset,
        max_num_metadatas: given_max_num_metadatas
      }
    end

    let(:target_result)           do
      num_courses = courses_count - given_metadata_sequence_number_offset

      {
        course_responses: num_courses.times.map do |index|
          {
            uuid: SecureRandom.uuid,
            initial_ecosystem_uuid: SecureRandom.uuid,
            metadata_sequence_number: index
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
        response_status, response_body = fetch_course_metadatas(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = fetch_course_metadatas(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the FetchCourseMetadatas service is called with the correct course data" do
        response_status, response_body = fetch_course_metadatas(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_result" do
        response_status, response_body = fetch_course_metadatas(request_payload: request_payload)
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
    let(:given_event_request_1)          do
      {
        request_uuid: given_request_1_uuid,
        event_types: given_event_types_1,
        course_uuid: given_course_1_uuid,
        sequence_number_offset: given_sequence_number_offset_1
      }
    end

    let(:given_request_2_uuid)           { SecureRandom.uuid }
    let(:given_event_types_2)            do
      CourseEvent.types.keys.sample(rand(CourseEvent.types.size) + 1)
    end
    let(:given_course_2_uuid)            { SecureRandom.uuid }
    let(:given_sequence_number_offset_2) { rand(1000000) }
    let(:given_event_request_2)          do
      {
        request_uuid: given_request_2_uuid,
        event_types: given_event_types_2,
        course_uuid: given_course_2_uuid,
        sequence_number_offset: given_sequence_number_offset_2
      }
    end

    let(:given_event_requests)          { [ given_event_request_1, given_event_request_2 ] }
    let(:given_max_num_events)          { 1000 }

    let(:request_payload)               do
      { course_event_requests: given_event_requests, max_num_events: given_max_num_events }
    end

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

  def update_course_active_dates(request_payload:)
    make_post_request(
      route: '/update_course_active_dates',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

  def fetch_course_metadatas(request_payload:)
    make_post_request(
      route: '/fetch_course_metadatas',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
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
