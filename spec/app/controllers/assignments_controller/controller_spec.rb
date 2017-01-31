require 'rails_helper'

RSpec.describe AssignmentsController, type: :request do
  let(:given_assignment_uuid)                   { SecureRandom.uuid }

  context '#create_update' do
    let(:given_sequence_number)                 { rand(10) }
    let(:given_is_deleted)                      { false }
    let(:given_ecosystem_uuid)                  { SecureRandom.uuid }
    let(:given_student_uuid)                    { SecureRandom.uuid }
    let(:given_assignment_type)                 { 'reading' }
    let(:given_assigned_book_container_uuid)    { SecureRandom.uuid }
    let(:given_assigned_book_container_uuids)   { [ given_assigned_book_container_uuid ] }
    let(:given_goal_num_tutor_assigned_spes)    { 2 }
    let(:given_spes_are_assigned)               { true }
    let(:given_goal_num_tutor_assigned_pes)     { 1 }
    let(:given_pes_are_assigned)                { false }

    let(:given_assigned_exercise_trial_uuid)    { SecureRandom.uuid }
    let(:given_assigned_exercise_exercise_uuid) { SecureRandom.uuid }
    let(:given_assigned_exercise_is_spe)        { false }
    let(:given_assigned_exercise_is_pe)         { true }

    let(:given_assigned_exercises)              do
      [
        {
          trial_uuid: given_assigned_exercise_trial_uuid,
          exercise_uuid: given_assigned_exercise_exercise_uuid,
          is_spe: given_assigned_exercise_is_spe,
          is_pe: given_assigned_exercise_is_pe
        }
      ]
    end

    let(:given_assignments)                     do
      [
        {
          assignment_uuid: given_assignment_uuid,
          sequence_number: given_sequence_number,
          is_deleted: given_is_deleted,
          ecosystem_uuid: given_ecosystem_uuid,
          student_uuid: given_student_uuid,
          assignment_type: given_assignment_type,
          assigned_book_container_uuids: given_assigned_book_container_uuids,
          goal_num_tutor_assigned_spes: given_goal_num_tutor_assigned_spes,
          spes_are_assigned: given_spes_are_assigned,
          goal_num_tutor_assigned_pes: given_goal_num_tutor_assigned_pes,
          pes_are_assigned: given_pes_are_assigned,
          assigned_exercises: given_assigned_exercises
        }
      ]
    end

    let(:request_payload)                       { { assignments: given_assignments } }

    let(:target_assignments)                    do
      given_assignments.map { |assignment| assignment.slice(:assignment_uuid, :sequence_number) }
    end
    let(:target_result)                         { { updated_assignments: target_assignments } }
    let(:target_response)                       { target_result }

    let(:service_double)                        do
      object_double(Services::CreateUpdateAssignments::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each)                               do
      allow(Services::CreateUpdateAssignments::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = create_update_assignments(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = create_update_assignments(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the CreateUpdateAssignments service is called with the correct course data" do
        response_status, response_body = create_update_assignments(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = create_update_assignments(request_payload: request_payload)
        expect(response_body.deep_symbolize_keys).to eq(target_response)
      end
    end
  end

  context '#fetch_pes' do
    let(:given_max_num_exercises)               { rand(10) }
    let(:given_assignment_uuid_2)               { SecureRandom.uuid }
    let(:given_max_num_exercises_2)             { rand(10) }

    let(:given_pe_requests)                     do
      [
        { assignment_uuid: given_assignment_uuid,   max_num_exercises: given_max_num_exercises },
        { assignment_uuid: given_assignment_uuid_2, max_num_exercises: given_max_num_exercises_2 }
      ]
    end

    let(:target_pe_responses)                   do
      [
        {
          assignment_uuid: given_assignment_uuid,
          exercise_uuids: given_max_num_exercises.times.map{ SecureRandom.uuid },
          assignment_status: 'assignment_ready'
        },
        {
          assignment_uuid: given_assignment_uuid_2,
          exercise_uuids: [],
          assignment_status: 'assignment_unready'
        }
      ]
    end

    let(:request_payload)                       { { pe_requests: given_pe_requests } }

    let(:target_result)                         { { pe_responses: target_pe_responses } }
    let(:target_response)                       { target_result }

    let(:service_double)                        do
      object_double(Services::FetchAssignmentPes::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each)                               do
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

  context '#fetch_spes' do
    let(:given_max_num_exercises)               { rand(10) }
    let(:given_assignment_uuid_2)               { SecureRandom.uuid }
    let(:given_max_num_exercises_2)             { rand(10) }

    let(:given_spe_requests)                    do
      [
        { assignment_uuid: given_assignment_uuid,   max_num_exercises: given_max_num_exercises },
        { assignment_uuid: given_assignment_uuid_2, max_num_exercises: given_max_num_exercises_2 }
      ]
    end

    let(:target_spe_responses)                  do
      [
        {
          assignment_uuid: given_assignment_uuid,
          exercise_uuids: given_max_num_exercises.times.map{ SecureRandom.uuid },
          assignment_status: 'assignment_ready'
        },
        {
          assignment_uuid: given_assignment_uuid_2,
          exercise_uuids: [],
          assignment_status: 'assignment_unready'
        }
      ]
    end

    let(:request_payload)                       { { spe_requests: given_spe_requests } }

    let(:target_result)                         { { spe_responses: target_spe_responses } }
    let(:target_response)                       { target_result }

    let(:service_double)                        do
      object_double(Services::FetchAssignmentSpes::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each)                               do
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

  protected

  def create_update_assignments(request_payload:)
    make_post_request(
      route: '/create_update_assignments',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

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
end
