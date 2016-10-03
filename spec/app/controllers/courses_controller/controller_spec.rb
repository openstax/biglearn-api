require 'rails_helper'

RSpec.describe CoursesController, type: :request do
  let(:request_payload) { 
    {
      course_uuid: given_course_data.uuid,
      ecosystem_uuid: given_course_data.ecosystem_uuid
    }
  }

  let(:given_course_data) {
    build(:course, ecosystem_uuid: ecosystem.uuid)
  }

  let(:ecosystem) {
    build(:ecosystem)
  }

  let(:target_result) {
    {
      created_course_uuid: given_course_data.uuid
    }
  }

  let(:service_double) {
    dbl = object_double(Services::CreateCourse::Service.new)
    allow(dbl).to receive(:process)
              .with(**request_payload)
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
      expect(response_body.fetch('created_course_uuid')).to eq(given_course_data.uuid)
    end
  end
end

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
