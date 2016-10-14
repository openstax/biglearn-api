require 'rails_helper'

RSpec.describe CoursesController, type: :request do
  let(:request_payload) {
    {} # an empty request is very invalid
  }



  context "when a valid request is made" do
    it "the request and response payloads are validated against their schemas" do
      expect_any_instance_of(RosterController).to receive(:update).and_call_original
      status, body = make_json_request(route: '/update_roster', payload: request_payload)
      expect(status).to eq(400)
      expect(body['errors']).to include 'request body failed validation'
    end

  end
end
