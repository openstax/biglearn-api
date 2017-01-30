require 'rails_helper'

RSpec.describe CourseEcosystemsController, type: :request do
  context '#prepare' do
    let(:given_preparation_uuid)        { SecureRandom.uuid }
    let(:given_course_uuid)             { SecureRandom.uuid }
    let(:given_sequence_number)         { rand(100) }
    let(:given_next_ecosystem_uuid)     { SecureRandom.uuid }

    let(:given_from_ecosystem_uuid)     { SecureRandom.uuid }
    let(:given_to_ecosystem_uuid)       { given_next_ecosystem_uuid }
    let(:given_cnx_pagemodule_mappings) { [] }
    let(:given_exercise_mappings)       { [] }

    let(:given_ecosystem_map)           do
      {
        from_ecosystem_uuid: given_from_ecosystem_uuid,
        to_ecosystem_uuid: given_to_ecosystem_uuid,
        cnx_pagemodule_mappings: given_cnx_pagemodule_mappings,
        exercise_mappings: given_exercise_mappings
      }
    end

    let(:request_payload)               do
      {
        preparation_uuid: given_preparation_uuid,
        course_uuid: given_course_uuid,
        sequence_number: given_sequence_number,
        next_ecosystem_uuid: given_next_ecosystem_uuid,
        ecosystem_map: given_ecosystem_map
      }
    end

    let(:target_result)                 { { status: 'accepted' } }
    let(:target_response)               { target_result }

    let(:service_double)                do
      object_double(Services::PrepareCourseEcosystem::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each)                       do
      allow(Services::PrepareCourseEcosystem::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = prepare_course_ecosystem(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = prepare_course_ecosystem(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the PrepareCourseEcosystem service is called with the correct course data" do
        response_status, response_body = prepare_course_ecosystem(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = prepare_course_ecosystem(request_payload: request_payload)
        expect(response_body).to eq(target_response.deep_stringify_keys)
      end
    end
  end

  context '#update' do
    let(:given_request_uuid_1)     { SecureRandom.uuid }
    let(:given_preparation_uuid_1) { SecureRandom.uuid }

    let(:given_request_uuid_2)     { SecureRandom.uuid }
    let(:given_preparation_uuid_2) { SecureRandom.uuid }

    let(:given_update_requests)    do
      [
        {
          request_uuid: given_request_uuid_1,
          preparation_uuid: given_preparation_uuid_1
        },
        {
          request_uuid: given_request_uuid_2,
          preparation_uuid: given_preparation_uuid_2
        }
      ]
    end

    let(:request_payload)          { { update_requests: given_update_requests } }

    let(:valid_update_statuses)    do
      ['preparation_unknown', 'preparation_obsolete', 'updated_but_unready', 'updated_and_ready']
    end

    let(:target_result)            do
      {
        update_responses: given_update_requests.map do |update_request|
          {
            request_uuid: update_request[:request_uuid],
            update_status: valid_update_statuses.sample
          }
        end
      }
    end
    let(:target_response)          { target_result }

    let(:service_double)           do
      object_double(Services::UpdateCourseEcosystem::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each)                  do
      allow(Services::UpdateCourseEcosystem::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = update_course_ecosystem(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = update_course_ecosystem(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the UpdateCourseEcosystem service is called with the correct course data" do
        response_status, response_body = update_course_ecosystem(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = update_course_ecosystem(request_payload: request_payload)
        expect(response_body).to eq(target_response.deep_stringify_keys)
      end
    end
  end

  context '#status' do
    let(:given_request_uuid)  { SecureRandom.uuid }

    let(:given_course_uuid_1) { SecureRandom.uuid }
    let(:given_course_uuid_2) { SecureRandom.uuid }

    let(:given_course_uuids)  { [given_course_uuid_1, given_course_uuid_2] }

    let(:request_payload)     do
      { request_uuid: given_request_uuid, course_uuids: given_course_uuids }
    end

    let(:target_result)       do
      {
        course_statuses: given_course_uuids.map do |course_uuid|
          {
            course_uuid: course_uuid,
            course_is_known: [true, false].sample,
            current_ecosystem_preparation_uuid: SecureRandom.uuid,
            current_ecosystem_status: {
              ecosystem_uuid: SecureRandom.uuid,
              ecosystem_is_known: [true, false].sample,
              ecosystem_is_prepared: [true, false].sample,
              precompute_is_complete: [true, false].sample
            },
            next_ecosystem_status: {
              ecosystem_uuid: SecureRandom.uuid,
              ecosystem_is_known: [true, false].sample,
              ecosystem_is_prepared: [true, false].sample,
              precompute_is_complete: [true, false].sample
            }
          }
        end
      }
    end
    let(:target_response)     { target_result }

    let(:service_double)      do
      object_double(Services::CourseEcosystemStatus::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each)             do
      allow(Services::CourseEcosystemStatus::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = course_ecosystem_status(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = course_ecosystem_status(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the CourseEcosystemStatus service is called with the correct course data" do
        response_status, response_body = course_ecosystem_status(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = course_ecosystem_status(request_payload: request_payload)
        expect(response_body).to eq(target_response.deep_stringify_keys)
      end
    end
  end

  protected

  def prepare_course_ecosystem(request_payload:)
    make_post_request(
      route: '/prepare_course_ecosystem',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

  def update_course_ecosystem(request_payload:)
    make_post_request(
      route: '/update_course_ecosystems',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

  def course_ecosystem_status(request_payload:)
    make_post_request(
      route: '/fetch_course_ecosystem_statuses',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end
end
