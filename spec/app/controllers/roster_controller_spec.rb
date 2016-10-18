require 'rails_helper'

RSpec.describe CoursesController, type: :request do
  let(:request_payload) {
    {} # an empty request is very invalid
  }

  let(:course){ FactoryGirl.create(:course) }

  context "when a valid request is made" do
    it "the request and response payloads are validated against their schemas" do
      expect_any_instance_of(RosterController).to receive(:update).and_call_original
      status, body = make_json_request(route: '/update_roster', payload: request_payload)
      expect(status).to eq(400)
      expect(body['errors']).to include 'request body failed validation'
    end
  end

  context "with a vaild payload" do
    it "calls the service" do
      expect_any_instance_of(Services::Roster::Update).to receive(:process!)
      container_uuid = SecureRandom.uuid
      rosters = [{ 'sequence_number': 0, 'course_uuid' => course.uuid,
                   'course_containers': [
                                          {
                                            'parent_container_uuid' => course.uuid,
                                            'container_uuid' => container_uuid
                                          }
                                        ],
                   'students': [
                                 {
                                   'student_uuid' => SecureRandom.uuid,
                                   'container_uuid' => container_uuid
                                 }
                               ]
                 }]
      payload = request_payload.merge('rosters': rosters)

      status, body = make_json_request(route: '/update_roster', payload: payload)
      expect(status).to eq(200)
      expect(body).to eq({"updated_course_uuids"=>[course.uuid]})
    end
  end

end
