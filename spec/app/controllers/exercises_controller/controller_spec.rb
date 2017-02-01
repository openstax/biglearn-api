require 'rails_helper'

RSpec.describe ExercisesController, type: :request do

  context '#fetch_assignment_pes' do
    let(:given_assignment_uuid_1)   { SecureRandom.uuid }
    let(:given_max_num_exercises_1) { rand(10) }
    let(:given_assignment_uuid_2)   { SecureRandom.uuid }
    let(:given_max_num_exercises_2) { rand(10) }

    let(:given_pe_requests)         do
      [
        { assignment_uuid: given_assignment_uuid_1, max_num_exercises: given_max_num_exercises_1 },
        { assignment_uuid: given_assignment_uuid_2, max_num_exercises: given_max_num_exercises_2 }
      ]
    end

    let(:target_pe_responses)       do
      [
        {
          assignment_uuid: given_assignment_uuid_1,
          exercise_uuids: given_max_num_exercises_1.times.map{ SecureRandom.uuid },
          assignment_status: 'assignment_ready'
        },
        {
          assignment_uuid: given_assignment_uuid_2,
          exercise_uuids: [],
          assignment_status: 'assignment_unready'
        }
      ]
    end

    let(:request_payload)           { { pe_requests: given_pe_requests } }

    let(:target_result)             { { pe_responses: target_pe_responses } }
    let(:target_response)           { target_result }

    let(:service_double)            do
      object_double(Services::FetchAssignmentPes::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each)                   do
      allow(Services::FetchAssignmentPes::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = fetch_assignment_pes(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = fetch_assignment_pes(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the FetchAssignmentPes service is called with the correct course data" do
        response_status, response_body = fetch_assignment_pes(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = fetch_assignment_pes(request_payload: request_payload)
        expect(response_body.deep_symbolize_keys).to eq(target_response)
      end
    end
  end

  context '#fetch_assignment_spes' do
    let(:given_assignment_uuid_1)   { SecureRandom.uuid }
    let(:given_max_num_exercises_1) { rand(10) }
    let(:given_assignment_uuid_2)   { SecureRandom.uuid }
    let(:given_max_num_exercises_2) { rand(10) }

    let(:given_spe_requests)        do
      [
        { assignment_uuid: given_assignment_uuid_1, max_num_exercises: given_max_num_exercises_1 },
        { assignment_uuid: given_assignment_uuid_2, max_num_exercises: given_max_num_exercises_2 }
      ]
    end

    let(:target_spe_responses)      do
      [
        {
          assignment_uuid: given_assignment_uuid_1,
          exercise_uuids: given_max_num_exercises_1.times.map{ SecureRandom.uuid },
          assignment_status: 'assignment_ready'
        },
        {
          assignment_uuid: given_assignment_uuid_2,
          exercise_uuids: [],
          assignment_status: 'assignment_unready'
        }
      ]
    end

    let(:request_payload)           { { spe_requests: given_spe_requests } }

    let(:target_result)             { { spe_responses: target_spe_responses } }
    let(:target_response)           { target_result }

    let(:service_double)            do
      object_double(Services::FetchAssignmentSpes::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each)                   do
      allow(Services::FetchAssignmentSpes::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = fetch_assignment_spes(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = fetch_assignment_spes(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the FetchAssignmentSpes service is called with the correct course data" do
        response_status, response_body = fetch_assignment_spes(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = fetch_assignment_spes(request_payload: request_payload)
        expect(response_body.deep_symbolize_keys).to eq(target_response)
      end
    end
  end

  context '#fetch_practice_worst_areas' do
    let(:given_student_uuid_1)                  { SecureRandom.uuid }
    let(:given_max_num_exercises_1)             { rand(10) }
    let(:given_student_uuid_2)                  { SecureRandom.uuid }
    let(:given_max_num_exercises_2)             { rand(10) }

    let(:given_worst_areas_requests)   do
      [
        { student_uuid: given_student_uuid_1, max_num_exercises: given_max_num_exercises_1 },
        { student_uuid: given_student_uuid_2, max_num_exercises: given_max_num_exercises_2 }
      ]
    end

    let(:target_worst_areas_responses) do
      [
        {
          student_uuid: given_student_uuid_1,
          exercise_uuids: given_max_num_exercises_1.times.map{ SecureRandom.uuid },
          student_status: 'student_ready'
        },
        {
          student_uuid: given_student_uuid_2,
          exercise_uuids: [],
          student_status: 'student_unready'
        }
      ]
    end

    let(:request_payload)                       do
      { worst_areas_requests: given_worst_areas_requests }
    end

    let(:target_result)                         do
      { worst_areas_responses: target_worst_areas_responses }
    end
    let(:target_response)                       { target_result }

    let(:service_double)                        do
      object_double(Services::FetchPracticeWorstAreasExercises::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each)                             do
      allow(Services::FetchPracticeWorstAreasExercises::Service).to(
        receive(:new).and_return(service_double)
      )
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = fetch_practice_worst_areas(
          request_payload: request_payload
        )
      end

      it "the response has status 200 (success)" do
        response_status, response_body = fetch_practice_worst_areas(
          request_payload: request_payload
        )
        expect(response_status).to eq(200)
      end

      it "the FetchAssignmentPes service is called with the correct course data" do
        response_status, response_body = fetch_practice_worst_areas(
          request_payload: request_payload
        )
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = fetch_practice_worst_areas(
          request_payload: request_payload
        )
        expect(response_body.deep_symbolize_keys).to eq(target_response)
      end
    end
  end

  protected

  def fetch_assignment_pes(request_payload:)
    make_post_request(
      route: '/fetch_assignment_pes',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

  def fetch_assignment_spes(request_payload:)
    make_post_request(
      route: '/fetch_assignment_spes',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

  def fetch_practice_worst_areas(request_payload:)
    make_post_request(
      route: '/fetch_practice_worst_areas_exercises',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end
end