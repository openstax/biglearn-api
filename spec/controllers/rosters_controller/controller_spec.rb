require 'rails_helper'

RSpec.describe RostersController, type: :request do
  let(:given_request_uuid)                 { SecureRandom.uuid }
  let(:given_course_uuid)                  { SecureRandom.uuid }
  let(:given_sequence_number)              { rand(10) }

  let(:given_course_container_uuid)        { SecureRandom.uuid }
  let(:given_course_container_parent_uuid) { given_course_container_uuid }
  let(:given_created_at)                   { Time.current.iso8601(6) }
  let(:given_archived_at)                  { Time.current.iso8601(6) }
  let(:given_course_containers)            do
    [
      {
        container_uuid: given_course_container_uuid,
        parent_container_uuid: given_course_container_parent_uuid,
        created_at: given_created_at,
        archived_at: given_archived_at
      }
    ]
  end
  let(:given_students)                     { [] }

  let(:given_rosters)                      do
    [
      {
        request_uuid: given_request_uuid,
        course_uuid: given_course_uuid,
        sequence_number: given_sequence_number,
        course_containers: given_course_containers,
        students: given_students
      }
    ]
  end

  let(:request_payload)                    { { rosters: given_rosters } }

  let(:target_result)                      do
    { updated_rosters: [
      { request_uuid: given_request_uuid, updated_course_uuid: given_course_uuid }
    ] }
  end
  let(:target_response)                    { target_result }

  let(:service_double)                     do
    object_double(Services::UpdateRosters::Service.new).tap do |dbl|
      allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
    end
  end

  before(:each)                            do
    allow(Services::UpdateRosters::Service).to receive(:new).and_return(service_double)
  end

  context "when a valid request is made" do
    it "the request and response payloads are validated against their schemas" do
      expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
      response_status, response_body = update_rosters(request_payload: request_payload)
    end

    it "the response has status 200 (success)" do
      response_status, response_body = update_rosters(request_payload: request_payload)
      expect(response_status).to eq(200)
    end

    it "the UpdateRosters service is called with the correct roster data" do
      response_status, response_body = update_rosters(request_payload: request_payload)
      expect(service_double).to have_received(:process)
    end

    it "the response contains the target_response" do
      response_status, response_body = update_rosters(request_payload: request_payload)
      expect(response_body).to eq(target_response.deep_stringify_keys)
    end
  end

  protected

  def update_rosters(request_payload:)
    make_post_request(
      route: '/update_rosters',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end
end
