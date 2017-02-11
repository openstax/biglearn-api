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
        course_responses: courses_count.times.map{
          {
            uuid: SecureRandom.uuid
          }
        }
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
        response_status, response_body = fetch_course_metadatas()
      end

      it "the response has status 200 (success)" do
        response_status, response_body = fetch_course_metadatas()
        expect(response_status).to eq(200)
      end

      it "the FetchCourseMetadatas service is called with the correct course data" do
        response_status, response_body = fetch_course_metadatas()
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_result" do
        response_status, response_body = fetch_course_metadatas()
        expect(response_body).to eq(target_result.deep_stringify_keys)
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

  def fetch_course_metadatas()
    make_post_request(
      route: '/fetch_course_metadatas'
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

end

